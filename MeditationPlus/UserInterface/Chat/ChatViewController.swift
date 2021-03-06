//
//  ChatViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import UIKit
import SlackTextViewController
import DZNEmptyDataSet
import MessageUI
import RealmSwift
import CocoaLumberjack
import PureLayout
import Rswift

class ChatViewController: SLKTextViewController {
    // MARK: Services
    
    private var chatService: ChatService!
    
    private var profileService: ProfileService!
    
    // MARK: Data
    
    private var chatNotificationToken: NotificationToken?

    private var chatResults: Results<ChatItem>?
    
    lazy private var emojis: [String] =
    {
        return Array<String>(TextTools.sharedInstance.emoticons.keys.sort() { $0 < $1 })
    }()

    // MARK: Misc
    
    private var autocompletionVisible: Bool = false

    private var chatUpdateTimer: NSTimer?
    
    private var questionButton: UIBarButtonItem!
    
    private var refreshControl: UIRefreshControl!

    // MARK: Init

    init()
    {
        super.init(tableViewStyle: UITableViewStyle.Plain)

        chatService    = ChatService()
        profileService = ProfileService.sharedInstance
        
        tabBarItem     = UITabBarItem(title: nil, image: R.image.chatIcon(), tag: 0)
        questionButton = UIBarButtonItem(title: NSLocalizedString("ask.question.button.title", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatViewController.didPressQuestionButton(_:)))
    }

    required init(coder decoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle
    {
        return UITableViewStyle.Plain
    }

    // MARK: View life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        
        configure()
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        enableChatNotification()
        chatService.reloadChatItemsIfNeeded()
        
        startChatUpdateTimer()
        
        refreshControl.transform = tableView!.transform
        
        registerForPreviewingWithDelegate(self, sourceView: self.view)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        parentViewController?.navigationItem.setRightBarButtonItem(questionButton, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)

        stopChatUpdateTimer()
        parentViewController?.navigationItem.setRightBarButtonItem(nil, animated: true)
        refreshControl.endRefreshing()
    }

}

// MARK: - View controller configuration

extension ChatViewController
{
    private func configure()
    {
        bounces                = true
        shakeToClearEnabled    = true
        keyboardPanningEnabled = true
        
        view.clipsToBounds = true
        
        autoCompletionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autocompletion")
        registerPrefixesForAutoCompletion([":"])
        
        shouldScrollToBottomAfterKeyboardShows = true
        
        leftButton.setImage(R.image.smileyIcon(), forState: UIControlState.Normal)
        leftButton.tintColor = UIColor.grayColor()
        
        rightButton.setTitle("Send", forState: UIControlState.Normal)
        rightButton.tintColor = UIColor.orangeColor()
        
        textView.placeholder      = NSLocalizedString("chat.message.placeholder", comment: "")
        textView.placeholderColor = UIColor.lightGrayColor()
        
        textInputbar.autoHideRightButton = true
        textInputbar.maxCharCount        = 1000
        textInputbar.counterStyle        = SLKCounterStyle.Split
        
        typingIndicatorView?.canResignByTouch = true
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView?.registerNib(R.nib.otherMessageCell(), forCellReuseIdentifier: R.nib.otherMessageCell.name)
        tableView?.registerNib(R.nib.ownMessageCell(), forCellReuseIdentifier: R.nib.ownMessageCell.name)
        tableView?.separatorStyle       = .None
        tableView?.rowHeight            = UITableViewAutomaticDimension
        tableView?.scrollsToTop         = false
        tableView?.estimatedRowHeight   = 100.0
        tableView?.emptyDataSetSource   = self
        tableView?.emptyDataSetDelegate = self
        
        refreshControl                 = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor       = UIColor.orangeColor()
        refreshControl.addTarget(self, action: #selector(ChatViewController.updateChat), forControlEvents: UIControlEvents.ValueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    override func heightForAutoCompletionView() -> CGFloat
    {
        return 300
    }
}

// MARK: - Timer handling

extension ChatViewController
{
    
    private func startChatUpdateTimer()
    {
        chatUpdateTimer?.invalidate()
        chatUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ChatViewController.updateChat), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(chatUpdateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    private func stopChatUpdateTimer()
    {
        chatUpdateTimer?.invalidate()
        chatUpdateTimer = nil
    }
}

// MARK: - Data handling

extension ChatViewController
{
    private func enableChatNotification()
    {
        guard self.chatNotificationToken == nil else {
            return
        }
        
        let (chatNotificationToken, results) = chatService.chatItems
        {
            (changes: RealmCollectionChange<Results<ChatItem>>) in
            
            self.refreshControl.endRefreshing()
            
            switch changes {
            case .Initial(_):
                self.tableView?.reloadData()
            case .Update(_, let deletions, let insertions, let modifications):
                let indexPathsToInsert = insertions.map { NSIndexPath(forRow: $0, inSection: 0) }
                
                self.tableView?.beginUpdates()
                self.tableView?.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Automatic)
                self.tableView?.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                self.tableView?.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                self.tableView?.endUpdates()
            case .Error(let error):
                DDLogError(error.localizedDescription)
                break
            }
        }
        
        self.chatNotificationToken = chatNotificationToken
        self.chatResults = results
    }
    
    private func disableChatNotification()
    {
        chatNotificationToken?.stop()
        chatNotificationToken = nil
    }

    func updateChat() {
        chatService.reloadChatItemsIfNeeded(true)
        {
            (serviceResult) in
            
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Actions

extension ChatViewController
{
    // MARK: SLKTextViewController action methods
    
    override func didPressLeftButton(sender: AnyObject!)
    {
        autocompletionVisible = !autocompletionVisible
        self.showAutoCompletionView(autocompletionVisible)
    }

    override func didPressRightButton(sender: AnyObject!)
    {
        self.textView.refreshFirstResponder()

        let message: String? = self.textView.text.copy() as? String

        super.didPressRightButton(sender)

        guard message?.characters.count ?? 0 > 0 else {
            NotificationManager.displayStatusBarNotification(NSLocalizedString("empty.message.error", comment: ""))
            return
        }
        
        chatService.postMessage(message!)
        {
            (result: ServiceResult) in
            
            if case ServiceResult.Failure(_) = result {
                NotificationManager.displayStatusBarNotification(NSLocalizedString("message.sending.failed.error", comment: ""))
            }
        }
    }

    // MARK: Other action methods
    
    func didPressQuestionButton(button: UIBarButtonItem)
    {
        textInputbar.textView.becomeFirstResponder()
        
        if let originalText = self.textView.text, regex = try? NSRegularExpression(pattern: "^\\s*q:\\s*", options: .CaseInsensitive) {
            let modifiedText   = regex.stringByReplacingMatchesInString(originalText, options: .WithTransparentBounds, range: NSMakeRange(0, originalText.characters.count), withTemplate: "")
            self.textView.text = "Q: " + modifiedText
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numRows = 0
        
        if tableView == self.autoCompletionView {
            numRows = self.emojis.count
        } else if section == 0 {
            numRows = self.chatResults?.count ?? 0
        }
        
        return numRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell!

        if tableView == self.tableView {
            if let chatResults = self.chatResults where indexPath.section == 0 && indexPath.row < chatResults.count {
                let chatItem = chatResults[indexPath.row]
                if chatItem.me ?? false {
                    cell = tableView.dequeueReusableCellWithIdentifier(R.nib.ownMessageCell.name, forIndexPath: indexPath)
                    (cell as? MessageCell)?.type = MessageCellType.Own
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier(R.nib.otherMessageCell.name, forIndexPath: indexPath)
                    (cell as? MessageCell)?.type = MessageCellType.Other
                }

                if cell is MessageCell {
                    (cell as? MessageCell)?.configureWithChatItem(chatItem)
                }
            }
        } else {
            cell                  = tableView.dequeueReusableCellWithIdentifier("autocompletion", forIndexPath: indexPath)
            cell.textLabel?.text  = self.emojis[indexPath.row]
            cell.imageView?.image = UIImage(named: TextTools.sharedInstance.emoticons[self.emojis[indexPath.row]]!)
        }
        
        cell.transform = tableView.transform

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController
{
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        (cell as? MessageCell)?.delegate = self
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        (cell as? MessageCell)?.delegate = nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if tableView == self.autoCompletionView {
            textInputbar.textView.insertText(self.emojis[indexPath.row])
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate Method

extension ChatViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        switch result {
            case MFMailComposeResultCancelled:
                break
            case MFMailComposeResultSent:
                NotificationManager.displayStatusBarNotification(NSLocalizedString("mail.report.sent.title", comment: ""))
            case MFMailComposeResultSaved:
                NotificationManager.displayStatusBarNotification(NSLocalizedString("mail.report.saved.title", comment: ""))
            case MFMailComposeResultFailed:
                NotificationManager.displayNotification(error?.localizedDescription ?? NSLocalizedString("mail.report.failed.title", comment: ""))
            default:
                break
        }

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate
{
    
    func didPressReportButton(button: UIButton, chatItem: ChatItem?)
    {
        let alertController = UIAlertController(title: NSLocalizedString("report.alert.title", comment: ""), message: NSLocalizedString("report.alert.description", comment: ""), preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let reportAction = UIAlertAction(title: "Report ", style: UIAlertActionStyle.Destructive) {
            (action) -> Void in
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            
            if chatItem != nil {
                self.rapportChatItem(chatItem!)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(reportAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView               = button
            popover.sourceRect               = button.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.Any
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func rapportChatItem(chatItem: ChatItem)
    {
        
        if MFMailComposeViewController.canSendMail() {
            let title = NSLocalizedString("report.mail.title", comment: "")
            let body  = String(format: NSLocalizedString("report.mail.body.format username: %@, message: %@, messsageId: %@", comment: ""), chatItem.username ?? "", chatItem.message ?? "", chatItem.cid ?? "")
            let to    = ["erik.luimes@gmail.com"]
            
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setSubject(title)
            composer.setMessageBody(body, isHTML: false)
            composer.setToRecipients(to)
            
            self.presentViewController(composer, animated: true, completion: nil)
        } else {
            NotificationManager.displayNotification(NSLocalizedString("mail.configuration.error", comment: ""))
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource

extension ChatViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
{
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return R.image.chatIcon()
    }

    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation!
    {
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 1.0, 0.0))
        animation.duration = 0.75
        animation.cumulative = true
        animation.repeatCount = 1000

        return animation
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool
    {
        return true
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension ChatViewController: UIViewControllerPreviewingDelegate
{
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        
        var viewController: UIViewController?
        
        let convertedPoint = self.view.convertPoint(location, toView: self.tableView!)
        
        guard let indexPath = tableView?.indexPathForRowAtPoint(convertedPoint) else {
            return nil
        }
        
        guard indexPath.row < chatResults?.count ?? 0 else {
            return nil
        }
        
        // There are 2 different message cells, 'Other' should be clickable on the left side, 'Own' on the right
        if let cell: MessageCell = tableView?.cellForRowAtIndexPath(indexPath) as? MessageCell {
            let tappableXMargin: CGFloat = 90
            
            switch cell.type {
            case .Own:
                guard location.x > UIScreen.mainScreen().bounds.width - tappableXMargin else {
                    return nil
                }
            case .Other:
                guard location.x < tappableXMargin else {
                    return nil
                }
            }
            
            if let chatItem = chatResults?[indexPath.row] {
                previewingContext.sourceRect = tableView!.convertRect(cell.frame, toView: self.view)
                viewController               = ProfileViewController(
                    nib: R.nib.profileView,
                    username: chatItem.username,
                    profileContentProvider: ProfileContentProvider(profileService: ProfileService.sharedInstance)
                )
            }
        }
        
        
        return viewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController)
    {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}