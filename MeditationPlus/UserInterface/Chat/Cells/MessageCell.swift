//
//  OtherMessageCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit
import DTCoreText
import DateTools
import SDWebImage

protocol MessageCellDelegate: NSObjectProtocol
{
    func didPressReportButton(button: UIButton, chatItem: ChatItem?)
}

enum MessageCellType
{
    case Own
    case Other
}

class MessageCell: UITableViewCell
{
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    weak var delegate: MessageCellDelegate?

    var type: MessageCellType = .Other
    
    private var chatItem: ChatItem?

    override func prepareForReuse()
    {
        chatItem              = nil
        avatarImageView.image = nil
        messageLabel.text     = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.borderColor        = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
        avatarImageView.layer.borderWidth        = 1
        avatarImageView.layer.masksToBounds      = true
        avatarImageView.layer.cornerRadius       = 35
        avatarImageView.layer.shouldRasterize    = true
        avatarImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    func configureWithChatItem(chatItem: ChatItem)
    {
        guard !chatItem.invalidated else {
            self.chatItem = nil
            return
        }
        
        self.chatItem = chatItem

        authorLabel.text = chatItem.username

        if chatItem.time != nil {
            self.dateLabel.text = chatItem.time!.timeAgoSinceNow()
        }

        let placeholderImage = NSURL(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")!
        let avatarURL        = chatItem.avatarURL ?? placeholderImage

        self.avatarImageView.sd_setImageWithURL(avatarURL, completed: { (image, error, cacheType, url) in
            if cacheType == SDImageCacheType.None {
                UIView.transitionWithView(self.avatarImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.avatarImageView.image = image
                }, completion: nil)
            } else {
                self.avatarImageView.image = image
            }
        })
        
        messageLabel.attributedText = chatItem.attributedText
    }

    @IBAction func didPressReportButton(sender: UIButton)
    {
        delegate?.didPressReportButton(sender, chatItem: chatItem)
    }
}
