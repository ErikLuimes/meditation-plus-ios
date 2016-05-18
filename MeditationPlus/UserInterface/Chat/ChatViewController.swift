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

    // MARK: Identifiers
    
    private let otherChatCellIdentifier = "otherChatCellIdentifier"
    private let ownChatCellIdentifier   = "ownChatCellIdentifier"

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
        
        tabBarItem     = UITabBarItem(title: nil, image: UIImage(named: "chat-icon"), tag: 0)
        questionButton = UIBarButtonItem(title: "Ask Question", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ChatViewController.didPressQuestionButton(_:)))
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
        
        leftButton.setImage(UIImage(named: "smiley"), forState: UIControlState.Normal)
        leftButton.tintColor = UIColor.grayColor()
        
        rightButton.setTitle("Send", forState: UIControlState.Normal)
        rightButton.tintColor = UIColor.orangeColor()
        
        textView.placeholder      = "Message"
        textView.placeholderColor = UIColor.lightGrayColor()
        
        textInputbar.autoHideRightButton = true
        textInputbar.maxCharCount        = 1000
        textInputbar.counterStyle        = SLKCounterStyle.Split
        
        typingIndicatorView?.canResignByTouch = true
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView?.registerNib(UINib(nibName: "OtherMessageCell", bundle: nil), forCellReuseIdentifier: otherChatCellIdentifier)
        tableView?.registerNib(UINib(nibName: "OwnMessageCell", bundle: nil), forCellReuseIdentifier: ownChatCellIdentifier)
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
            NotificationManager.displayStatusBarNotification("Please enter a message.")
            return
        }
        
        chatService.postMessage(message!)
        {
            (result: ServiceResult) in
            
            if case ServiceResult.Failure(_) = result {
                NotificationManager.displayStatusBarNotification("Failed sending message.")
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
                    cell = tableView.dequeueReusableCellWithIdentifier(self.ownChatCellIdentifier, forIndexPath: indexPath)
                    (cell as? MessageCell)?.type = MessageCellType.Own
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier(self.otherChatCellIdentifier, forIndexPath: indexPath)
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
                NotificationManager.displayStatusBarNotification("Report sent")
            case MFMailComposeResultSaved:
                NotificationManager.displayStatusBarNotification("Report saved")
            case MFMailComposeResultFailed:
                NotificationManager.displayNotification(error?.localizedDescription ?? "Somer error occurred, please try again later.")
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
        let alertController = UIAlertController(title: "Report inappropriate content", message: "By clicking the 'Report' button you can send us an email to report abuse and inappropriate content.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let rapportAction = UIAlertAction(title: "Report ", style: UIAlertActionStyle.Destructive) {
            (action) -> Void in
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            
            if chatItem != nil {
                self.rapportChatItem(chatItem!)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(rapportAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = button
            popover.sourceRect = button.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.Any
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func rapportChatItem(chatItem: ChatItem)
    {
        
        if MFMailComposeViewController.canSendMail() {
            let title = "Report inappropriate content"
            let body = "Dear sir/madam, \n\nI would like to report inappropriate content on the Meditator Shoutbox.\n\nusername:\n\(chatItem.username ?? "")\n\nmessage:\n\(chatItem.message ?? "")\n\nmessageId: \(chatItem.cid ?? "")"
            let to = ["erik.luimes@gmail.com"]
            
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setSubject(title)
            composer.setMessageBody(body, isHTML: false)
            composer.setToRecipients(to)
            
            self.presentViewController(composer, animated: true, completion: nil)
        } else {
            NotificationManager.displayNotification("Unable to use email.")
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource

extension ChatViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
{
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return UIImage(named: "chat-icon")
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
                viewController               = ProfileViewController(nibName: "ProfileViewController", bundle: nil, username: chatItem.username)
            }
        }
        
        
        return viewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController)
    {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}