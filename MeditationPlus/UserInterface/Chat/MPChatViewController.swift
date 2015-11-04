//
//  MPChatViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import SlackTextViewController

class MPChatViewController: SLKTextViewController {
    private let chatManager = MPChatManager()

    private let profilemanager = MPProfileManager.sharedInstance
    
    private var chats: [MPChatItem] = [MPChatItem]()

    private let otherChatCellIdentifier = "otherChatCellIdentifier"
    private let ownChatCellIdentifier   = "ownChatCellIdentifier"
    
    private var autocompletionVisible: Bool = false
    
    private var emojis: [String] = Array<String>(MPTextManager.sharedInstance.emoticons.keys)
    
    init() {
        super.init(tableViewStyle: UITableViewStyle.Plain)
        
        tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat-icon"), tag: 0)
        
        edgesForExtendedLayout   = .None
        tableView.separatorStyle = .None
    }

    required init!(coder decoder: NSCoder!) {
        super.init(coder: decoder)
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bounces                = true
        shakeToClearEnabled    = true
        keyboardPanningEnabled = true
        inverted               = false
        
        autoCompletionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autocompletion")
        registerPrefixesForAutoCompletion([":"])
        
        shouldScrollToBottomAfterKeyboardShows = false

        textView.placeholder      = "Message"
        textView.placeholderColor = UIColor.lightGrayColor()

        leftButton.setImage(UIImage(named: "smiley"), forState: UIControlState.Normal)
        leftButton.tintColor = UIColor.grayColor()
        
        rightButton.setTitle("Send", forState: UIControlState.Normal)
        rightButton.tintColor = UIColor.orangeColor()

        textInputbar.autoHideRightButton = true
        textInputbar.maxCharCount        = 1000
        textInputbar.counterStyle        = SLKCounterStyle.Split

        typingIndicatorView.canResignByTouch = true
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.rowHeight          = UITableViewAutomaticDimension
        tableView.scrollsToTop       = false
        tableView.estimatedRowHeight = 100.0
        tableView.registerNib(UINib(nibName: "MPOtherMessageCell", bundle: nil), forCellReuseIdentifier: otherChatCellIdentifier)
        tableView.registerNib(UINib(nibName: "MPOwnMessageCell", bundle: nil), forCellReuseIdentifier: ownChatCellIdentifier)
        
        chatManager.chatList({ (error) -> Void in
        }) { (chats) -> Void in
            self.chats.removeAll()
            self.chats += chats
            self.enrichChatsWithProfileData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            cell.textLabel?.text  = self.emojis[indexPath.row]
            cell.imageView?.image = UIImage(named: MPTextManager.sharedInstance.emoticons[self.emojis[indexPath.row]]!)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.autoCompletionView {
            acceptAutoCompletionWithString(self.emojis[indexPath.row])
        }
    }
    
    // MARK: - SLKTextViewController

    override func didPressLeftButton(sender: AnyObject!) {
        autocompletionVisible = !autocompletionVisible
        self.showAutoCompletionView(autocompletionVisible)
    }

    override func didPressRightButton(sender: AnyObject!) {
        
//        MPNotificationManager.displayStaticStatusBarNotification("Sending message ...")

        self.textView.refreshFirstResponder()

        let message = self.textView.text.copy() as! String

        super.didPressRightButton(sender)
        
        if message.characters.count == 0 {
            MPNotificationManager.displayStatusBarNotification("Please enter a message.")
            return
        }
        
        chatManager.postMessage(message, completion: { (chats: [MPChatItem]) -> Void in
            self.appendChats(chats)
        }) { (error: NSError?) -> Void in
            MPNotificationManager.displayStatusBarNotification("Failed sending message.")
        }
    }
    
    func appendChats(newChats: [MPChatItem]) {
        tableView.beginUpdates()
        let numChatsToAdd = newChats.count
        let startIndex    = chats.count
        let endIndex      = startIndex + numChatsToAdd
        
        chats += newChats
        
        var indexPathsToAdd = [NSIndexPath]()
        for index in startIndex..<endIndex {
            indexPathsToAdd.append(NSIndexPath(forRow: index, inSection: 0))
        }
        
        tableView.insertRowsAtIndexPaths(indexPathsToAdd, withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        if let indexPath = indexPathsToAdd.last {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        return 300
    }

    func enrichChatsWithProfileData() {
        let dispatchGroup = dispatch_group_create()
        
        var profiles: [String: MPProfile] = [String: MPProfile]()
        
        for username in Set(self.chats.map({ $0.username ?? ""})) {
            dispatch_group_enter(dispatchGroup)
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                self.profilemanager.profile(username, completion: { (profile: MPProfile) -> Void in
                    profiles[username] = profile
                    dispatch_group_leave(dispatchGroup)
                })
            })
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            for chat in self.chats where chat.username != nil{
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
                self.tableView.reloadData()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let path : NSIndexPath = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                })
            })
        });
    }
}

extension String {
    func md5() -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex

    }
}
