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

    private var chats: [MPChatItem] = [MPChatItem]()

    private let chatCellIdentifier = "chatCellIdentifier"
    
    private var emojis: [String]!
    
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

        self.bounces                = true
        self.shakeToClearEnabled    = true
        self.keyboardPanningEnabled = true
        self.inverted               = false
        
        
        self.emojis = ["m", "man", "machine", "block-a", "block-b", "bowtie", "boar", "boat", "book", "bookmark", "neckbeard", "metal", "fu", "feelsgood"];
        
        self.autoCompletionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autocompletion")
        self.registerPrefixesForAutoCompletion([":"])
//        registerPrefixesForAutoCompletion = [":"]
        
        self.shouldScrollToBottomAfterKeyboardShows = false

        self.textView.placeholder = "Message"
        self.textView.placeholderColor = UIColor.lightGrayColor()

        self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 140
        self.textInputbar.counterStyle = SLKCounterStyle.Split

        self.typingIndicatorView.canResignByTouch = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.scrollsToTop = false
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.registerNib(UINib(nibName: "MPOtherMessageCell", bundle: nil), forCellReuseIdentifier: self.chatCellIdentifier)
        self.chatManager.chatList({ (error) -> Void in
        }) { (chats) -> Void in
            self.chats.removeAll()
            self.chats += chats

            self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let path : NSIndexPath = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            })
        }
        self.view.backgroundColor = UIColor.whiteColor()
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
            cell = tableView.dequeueReusableCellWithIdentifier(self.chatCellIdentifier, forIndexPath: indexPath)
            if indexPath.section == 0 && indexPath.row < self.chats.count {
                let chatItem = self.chats[indexPath.row]
                if cell is MPOtherMessageCell {
                    (cell as? MPOtherMessageCell)?.configureWithChatItem(chatItem)
                    
                } else if cell is MPOwnMessageCell {
                    cell.textLabel?.text       = chatItem.username
                    cell.detailTextLabel?.text = chatItem.message
                }
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("autocompletion", forIndexPath: indexPath)
            cell.textLabel?.text = self.emojis[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - SLKTextViewController

    override func didPressLeftButton(sender: AnyObject!) {
        self.showAutoCompletionView(true)
    }

    override func didPressRightButton(sender: AnyObject!) {

        self.textView.refreshFirstResponder()

        let message = self.textView.text.copy() as! NSString

        let chatItem    = MPChatItem(username: MTAuthenticationManager.sharedInstance.loggedInUser!.username!, message: message as String)
        chatItem.createAttributedText()
        
        let insertIndex = self.chats.count
        self.chats.append(chatItem)
        
        let idxPath : NSIndexPath = NSIndexPath(forItem: insertIndex, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([idxPath], withRowAnimation: .Automatic)

//        self.tableView.slk_scrollToBottomAnimated(true)
        self.tableView.scrollToRowAtIndexPath(idxPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)

        super.didPressRightButton(sender)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        return 200
    }
}
