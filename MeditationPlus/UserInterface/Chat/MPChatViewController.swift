//
//  MPChatViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import SlackTextViewController
import DZNEmptyDataSet
import MessageUI
import RealmSwift
import CocoaLumberjack

class MPChatViewController: SLKTextViewController {
    // MARK: Services
    
    private var chatService: ChatService!
    
    private var profileService: ProfileService!
    
    // MARK: Data
    
    private var chatNotificationToken: NotificationToken?

    private var chatResults: Results<MPChatItem>?
    
    lazy private var emojis: [String] =
    {
        return Array<String>(MPTextManager.sharedInstance.emoticons.keys.sort() { $0 < $1 })
    }()

    // MARK: Identifiers
    
    private let otherChatCellIdentifier = "otherChatCellIdentifier"
    private let ownChatCellIdentifier = "ownChatCellIdentifier"

    // MARK: Misc
    
    private var autocompletionVisible: Bool = false

    private var chatUpdateTimer: NSTimer?

    private var emoticonButton: UIButton!

    // MARK: Init

    init() {
        super.init(tableViewStyle: UITableViewStyle.Plain)

        chatService = ChatService()
        
        profileService = ProfileService.sharedInstance
        
        tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "chat-icon"), tag: 0)

        tableView?.separatorStyle = .None

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "orange_q"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MPChatViewController.didPressQuestionButton(_:)))
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }

    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        enableChatNotification()
        chatService.reloadChatItemsIfNeeded()
        
        startChatUpdateTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        stopChatUpdateTimer()
    }

    // MARK: Logic handling
    
    private func startChatUpdateTimer()
    {
        chatUpdateTimer?.invalidate()
        chatUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(MPChatViewController.updateChat), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(chatUpdateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    private func stopChatUpdateTimer()
    {
        chatUpdateTimer?.invalidate()
        chatUpdateTimer = nil
    }
    
    private func enableChatNotification()
    {
        guard self.chatNotificationToken == nil else {
            return
        }
        
        let (chatNotificationToken, results) = chatService.chatItems
        {
            (changes: RealmCollectionChange<Results<MPChatItem>>) in
            
            switch changes {
            case .Initial(let results):
                self.tableView?.reloadData()
                if results.count > 0 {
                    self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: results.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
            case .Update(_, let deletions, let insertions, let modifications):
                let indexPathsToInsert = insertions.map { NSIndexPath(forRow: $0, inSection: 0) }
                
                self.tableView?.beginUpdates()
                self.tableView?.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Automatic)
                self.tableView?.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                self.tableView?.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                self.tableView?.endUpdates()
                
                if let indexPath = indexPathsToInsert.last {
                    self.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
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
    }
    
    // MARK: Actions
    
    func didPressQuestionButton(button: UIBarButtonItem) {
        NSLog("did press button")
    }

    // MARK: SLKTextViewController methods

    override func didPressLeftButton(sender: AnyObject!) {
        autocompletionVisible = !autocompletionVisible
        self.showAutoCompletionView(autocompletionVisible)
    }

    func didPressEmoticonButton(sener: UIButton) {
        autocompletionVisible = !autocompletionVisible
        self.showAutoCompletionView(autocompletionVisible)
    }

    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()

        let message: String? = self.textView.text.copy() as? String

        super.didPressRightButton(sender)

        guard message?.characters.count ?? 0 > 0 else {
            MPNotificationManager.displayStatusBarNotification("Please enter a message.")
            return
        }
        
        chatService.postMessage(message!)
        {
            (result: ServiceResult) in
            
            if case ServiceResult.Failure(_) = result {
                MPNotificationManager.displayStatusBarNotification("Failed sending message.")
            }
        }
    }


    override func heightForAutoCompletionView() -> CGFloat {
        return 300
    }

//    func enrichChatsWithProfileData(animated: Bool = true) {
//        let dispatchGroup = dispatch_group_create()
//
//        var profiles: [String:MPProfile] = [String: MPProfile]()
//
//        for username in Set(self.chats.map({ $0.username ?? "" })) {
//            dispatch_group_enter(dispatchGroup)
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//                self.profilemanager.profile(username, completion: {
//                    (profile: MPProfile) -> Void in
//                    profiles[username] = profile
//                    dispatch_group_leave(dispatchGroup)
//                })
//            })
//        }
//
//        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//            for chat in self.chats where chat.username != nil {
//                if let profile: MPProfile = profiles[chat.username!] {
//                    if let _ = profile.img, imgURL = NSURL(string: profile.img!) where profile.img!.characters.count > 0 {
//                        chat.avatarURL = imgURL
//                    } else if let _ = profile.img where profile.img!.rangeOfString("@") != nil {
//                        let emailhash = profile.img!.md5()
//                        let avatarURL = NSURL(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!
//
//
//                        chat.avatarURL = avatarURL
//
//                    } else if let email = profile.email {
//                        let emailhash = email.md5()
//                        let avatarURL = NSURL(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!
//
//
//                        chat.avatarURL = avatarURL
//                    }
//                }
//            }
//
//            dispatch_sync(dispatch_get_main_queue(), {
//                self.tableView?.reloadData()
////                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                let path: NSIndexPath = NSIndexPath(forRow: (self.tableView?.numberOfRowsInSection(0))! - 1, inSection: 0)
//                self.tableView?.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
////                })
//            })
//        })
//    }
}

// MARK: - View controller configuration

extension MPChatViewController
{
    private func configure()
    {
        bounces = true
        shakeToClearEnabled = true
        keyboardPanningEnabled = true
        inverted = false
        
        autoCompletionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autocompletion")
        registerPrefixesForAutoCompletion([":"])
        
        shouldScrollToBottomAfterKeyboardShows = false
        
        leftButton.setImage(UIImage(named: "smiley"), forState: UIControlState.Normal)
        leftButton.tintColor = UIColor.grayColor()
        
        rightButton.setTitle("Send", forState: UIControlState.Normal)
        rightButton.tintColor = UIColor.orangeColor()
        
        emoticonButton = UIButton(type: UIButtonType.Custom)
        emoticonButton.setImage(UIImage(named: "orange_q"), forState: .Normal)
        emoticonButton.addTarget(self, action: #selector(MPChatViewController.didPressEmoticonButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        textInputbar.insertSubview(emoticonButton, atIndex: 0)
        emoticonButton.sizeToFit()
        
        textView.placeholder = "Message"
        textView.placeholderColor = UIColor.lightGrayColor()
        
        textInputbar.autoHideRightButton = true
        textInputbar.maxCharCount = 1000
        textInputbar.counterStyle = SLKCounterStyle.Split
        
        typingIndicatorView?.canResignByTouch = true
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.scrollsToTop = false
        tableView?.estimatedRowHeight = 100.0
        tableView?.registerNib(UINib(nibName: "MPOtherMessageCell", bundle: nil), forCellReuseIdentifier: otherChatCellIdentifier)
        tableView?.registerNib(UINib(nibName: "MPOwnMessageCell", bundle: nil), forCellReuseIdentifier: ownChatCellIdentifier)
        
        tableView?.emptyDataSetSource = self
        tableView?.emptyDataSetDelegate = self
        
        self.view.clipsToBounds = true
    }
}

// MARK: - UITableViewDataSource

extension MPChatViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if tableView == self.autoCompletionView {
            numRows = self.emojis.count
        } else if section == 0 {
            numRows = self.chatResults?.count ?? 0
        }
        
        return numRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if tableView == self.tableView {
            if let chatResults = self.chatResults where indexPath.section == 0 && indexPath.row < chatResults.count {
                let chatItem = chatResults[indexPath.row]
                if chatItem.me ?? false {
                    cell = tableView.dequeueReusableCellWithIdentifier(self.ownChatCellIdentifier, forIndexPath: indexPath)
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier(self.otherChatCellIdentifier, forIndexPath: indexPath)
                }

                if cell is MPMessageCell {
                    (cell as? MPMessageCell)?.configureWithChatItem(chatItem)
                }
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("autocompletion", forIndexPath: indexPath)
            cell.textLabel?.text = self.emojis[indexPath.row]
            cell.imageView?.image = UIImage(named: MPTextManager.sharedInstance.emoticons[self.emojis[indexPath.row]]!)
        }

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? MPMessageCell)?.delegate = self
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? MPMessageCell)?.delegate = nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.autoCompletionView {
            textInputbar.textView.insertText(self.emojis[indexPath.row])
        }
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate Method

extension MPChatViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
            case MFMailComposeResultCancelled:
                break
            case MFMailComposeResultSent:
                MPNotificationManager.displayStatusBarNotification("Report sent")
            case MFMailComposeResultSaved:
                MPNotificationManager.displayStatusBarNotification("Report saved")
            case MFMailComposeResultFailed:
                MPNotificationManager.displayNotification(error?.localizedDescription ?? "Somer error occurred, please try again later.")
            default:
                break
        }

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - MPMessageCellDelegate

extension MPChatViewController: MPMessageCellDelegate
{
    
    func didPressReportButton(button: UIButton, chatItem: MPChatItem?) {
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
    
    func rapportChatItem(chatItem: MPChatItem) {
        
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
            MPNotificationManager.displayNotification("Unable to use email.")
        }
    }
}

// MARK: - DZNEmptyDataSetDelegate

extension MPChatViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
{
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "chat-icon")
    }

    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 1.0, 0.0))
        animation.duration = 0.75
        animation.cumulative = true
        animation.repeatCount = 1000

        return animation
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}