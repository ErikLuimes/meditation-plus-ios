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

    init() {
        super.init(collectionViewLayout: SLKMessageViewLayout())

        tabBarItem = UITabBarItem(title: "Chat", image: nil, tag: 0)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    required init!(coder decoder: NSCoder!) {
        super.init(coder: decoder)
    }
    
    override class func collectionViewLayoutForCoder(decoder: NSCoder) -> UICollectionViewLayout {
        let layout = SLKMessageViewLayout();
        return layout
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.inverted = false

        self.textView.placeholder = "Message"
        self.textView.placeholderColor = UIColor.lightGrayColor()

        self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 140
        self.textInputbar.counterStyle = SLKCounterStyle.Split

        self.typingIndicatorView.canResignByTouch = true

        self.collectionView!.registerClass(SLKMessageViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        
        self.chatManager.chatList(failure: { (error) -> Void in
            // refreshControl.endRefreshing()
            }) { (chats) -> Void in
                //self.meditatorDataSource.updateMeditators(meditators)
                //self.meditatorView.tableView.reloadData()
                //refreshControl.endRefreshing()
                self.chats.removeAll()
                self.chats += chats
                
                self.collectionView.reloadData()
        }

//        for index in 0...101 {
//            let message:NSString = "blaaat ertresdfg sdfgdisdf sdf sdf asdl ajsdlfj asldfk jasdlf kjasdfl kjasdfl kjasdfl kjasdf  f dfgsd fsdfg "
//            self.messages.addObject(message)
//        }
    }
    
    

    // MARK: - SLKTextViewController

    override func didPressLeftButton(sender: AnyObject!) {

    }

    override func didPressRightButton(sender: AnyObject!) {

        self.textView.refreshFirstResponder()

        let message = self.textView.text.copy() as! NSString

        let chatItem = MPChatItem(username: MTAuthenticationManager.sharedInstance.loggedInUser!.username, message: message as String)
//        self.messages.insertObject(message, atIndex: 0)
        self.chats.insert(chatItem, atIndex: 0)
        

        let idxPath : NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        self.collectionView.insertItemsAtIndexPaths([idxPath])

        self.collectionView.slk_scrollToBottomAnimated(true)

        super.didPressRightButton(sender)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chats.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> SLKMessageViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! SLKMessageViewCell
//        let message = self.messages.objectAtIndex(indexPath.row) as! NSString
        
        if indexPath.section == 0 && indexPath.row < self.chats.count {
            var chatItem = self.chats[indexPath.row]
            cell.titleLabel.text = chatItem.message
            cell.imageView.setImageWithURL(NSURL(string: "http://randomimage.setgetgo.com/get.php?height=400&width=400")!)
        }

//        cell.titleLabel.text = message as String

        return cell
    }

    func collectionView(collectionView: UICollectionView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let minHeight: CGFloat = 40.0

        let message = self.chats[indexPath.row].message! as NSString
        let width: CGFloat = CGRectGetWidth(collectionView.frame)

        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Left

        var attributes: NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSParagraphStyleAttributeName: paragraphStyle]

        let bounds: CGRect = message.boundingRectWithSize(CGSizeMake(width, 0.0), options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes as [NSObject : AnyObject], context: nil)

        if (message.length == 0) {
            return 0.0;
        }

        return max(CGRectGetHeight(bounds), minHeight)
    }

    // MARK: - UICollectionViewDataSource

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class _MPChatViewController: SLKTextViewController {
    private let chatManager = MPChatManager()

    private var chats: [MPChatItem] = [MPChatItem]()

    private let chatCellIdentifier = "chatCellIdentifier"
    
    init() {
        super.init(tableViewStyle: UITableViewStyle.Plain)
    }

    required init!(coder decoder: NSCoder!) {
        super.init(coder: decoder)
    }
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
        
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.chatCellIdentifier)
//        self.tableView.registerNib(UINib(nibName: "MPOtherMessageCell", bundle: nil), forCellReuseIdentifier: self.chatCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "MPOwnMessageCell", bundle: nil), forCellReuseIdentifier: self.chatCellIdentifier)
        self.chatManager.chatList(failure: { (error) -> Void in
            // refreshControl.endRefreshing()
        }) { (chats) -> Void in
            //self.meditatorDataSource.updateMeditators(meditators)
            //self.meditatorView.tableView.reloadData()
            //refreshControl.endRefreshing()
            self.chats.removeAll()
            self.chats += chats

            self.tableView.reloadData()
        }
//        self.view.backgroundColor = UIColor.greenColor()
        // Do any additional setup after loading the view.
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        
        if tableView == self.autoCompletionView {
            numRows = 0
        } else if section == 0 {
            numRows = self.chats.count
        }
        
        return numRows
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.chatCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.transform = self.tableView.transform
        
        if tableView == self.tableView {
            if indexPath.section == 0 && indexPath.row < self.chats.count {
                var chatItem = self.chats[indexPath.row]
                if cell is MPOtherMessageCell {
                    (cell as? MPOtherMessageCell)?.configureWithChatItem(chatItem)
                    
                } else if cell is MPOwnMessageCell {
                    cell.textLabel?.text       = chatItem.username
                    cell.detailTextLabel?.text = chatItem.message
                }
            }
        }
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 140
//    }
    
//    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//    {
//    #warning Incomplete method implementation.
//    // Returns the number of rows in the section.
//    
//    if ([tableView isEqual:self.autoCompletionView]) {
//    return 0;
//    }
//    
//    return 0;
//    }


}
