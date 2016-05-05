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
import Security

class MPChatViewController: SLKTextViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MPMessageCellDelegate, MFMailComposeViewControllerDelegate {
    private let chatManager = MPChatManager()

    private let profilemanager = MPProfileManager.sharedInstance

    private var chats: [MPChatItem] = [MPChatItem]()

    private let otherChatCellIdentifier = "otherChatCellIdentifier"
    private let ownChatCellIdentifier = "ownChatCellIdentifier"

    private var autocompletionVisible: Bool = false

    private var chatUpdateTimer: NSTimer?

    private var emojis: [String] = Array<String>(MPTextManager.sharedInstance.emoticons.keys.sort() {
                                                     $0 < $1
                                                 })

    private var emoticonButton: UIButton!

    init() {
        super.init(tableViewStyle: UITableViewStyle.Plain)

        tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat-icon"), tag: 0)

        edgesForExtendedLayout = .None
        tableView?.separatorStyle = .None

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "orange_q"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MPChatViewController.didPressQuestionButton(_:)))
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }

    func didPressQuestionButton(button: UIBarButtonItem) {
        NSLog("did press button")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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


        chatManager.chatList({
            (error) -> Void in
        }) {
            (chats) -> Void in
            self.chats.removeAll()
            self.chats += chats
            self.enrichChatsWithProfileData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        chatUpdateTimer?.invalidate()
        chatUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(MPChatViewController.updateChat), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(chatUpdateTimer!, forMode: NSRunLoopCommonModes)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        chatUpdateTimer?.invalidate()
    }

    func updateChat() {
        chatManager.chatList({
            (error) -> Void in
        }) {
            (chats) -> Void in
            if chats.count > 0 {
                self.appendChats(chats)
                self.enrichChatsWithProfileData()
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0

        if tableView == self.autoCompletionView {
            numRows = self.emojis.count
        } else if section == 0 {
            numRows = self.chats.count
        }

        return numRows
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if tableView == self.tableView {
            if indexPath.section == 0 && indexPath.row < self.chats.count {
                let chatItem = self.chats[indexPath.row]
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

    // MARK: - SLKTextViewController

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

        let message = self.textView.text.copy() as! String

        super.didPressRightButton(sender)

        if message.characters.count == 0 {
            MPNotificationManager.displayStatusBarNotification("Please enter a message.")
            return
        }

        chatManager.postMessage(message, completion: {
            (chats: [MPChatItem]) -> Void in
            self.appendChats(chats)
            self.enrichChatsWithProfileData()
        }) {
            (error: NSError?) -> Void in
            MPNotificationManager.displayStatusBarNotification("Failed sending message.")
        }
    }

    func appendChats(newChats: [MPChatItem]) {
        if newChats.count == 0 {
            return
        }

        tableView?.beginUpdates()
        let numChatsToAdd = newChats.count
        let startIndex = chats.count
        let endIndex = startIndex + numChatsToAdd

        chats += newChats

        var indexPathsToAdd = [NSIndexPath]()
        for index in startIndex ..< endIndex {
            indexPathsToAdd.append(NSIndexPath(forRow: index, inSection: 0))
        }

        tableView?.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Automatic)
        tableView?.endUpdates()

        if let indexPath = indexPathsToAdd.last {
            tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return 300
    }

    func enrichChatsWithProfileData(animated: Bool = true) {
        let dispatchGroup = dispatch_group_create()

        var profiles: [String:MPProfile] = [String: MPProfile]()

        for username in Set(self.chats.map({ $0.username ?? "" })) {
            dispatch_group_enter(dispatchGroup)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                self.profilemanager.profile(username, completion: {
                    (profile: MPProfile) -> Void in
                    profiles[username] = profile
                    dispatch_group_leave(dispatchGroup)
                })
            })
        }

        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            for chat in self.chats where chat.username != nil {
                if let profile: MPProfile = profiles[chat.username!] {
                    if let _ = profile.img, imgURL = NSURL(string: profile.img!) where profile.img!.characters.count > 0 {
                        chat.avatarURL = imgURL
                    } else if let _ = profile.img where profile.img!.rangeOfString("@") != nil {
                        let emailhash = profile.img!.md5()
                        let avatarURL = NSURL(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!


                        chat.avatarURL = avatarURL

                    } else if let email = profile.email {
                        let emailhash = email.md5()
                        let avatarURL = NSURL(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!


                        chat.avatarURL = avatarURL
                    }
                }
            }

            dispatch_sync(dispatch_get_main_queue(), {
                self.tableView?.reloadData()
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let path: NSIndexPath = NSIndexPath(forRow: (self.tableView?.numberOfRowsInSection(0))! - 1, inSection: 0)
                self.tableView?.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
//                })
            })
        })
    }

    // MARK: DZNEmptyDataSetDelegate
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
    // MARK: MPMessageCellDelegate

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

    // MARK: MFMailComposeViewControllerDelegate Method
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

extension String {
    func md5() -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }

        var digestHex = ""
        for index in 0 ..< Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }

        return digestHex

    }
}
