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
        avatarImageView.image = nil
        chatItem = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithChatItem(chatItem: ChatItem)
    {
        guard !chatItem.invalidated else {
            self.chatItem = nil
            return
        }
        
        self.chatItem = chatItem

        authorLabel.text = (chatItem.username)

        if chatItem.time != nil {
            self.dateLabel.text = chatItem.time!.timeAgoSinceNow()
        }

        let placeholderImage = NSURL(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")!
        let avatarURL = chatItem.avatarURL ?? placeholderImage
        self.avatarImageView.sd_setImageWithURL(avatarURL)

        messageLabel.attributedText = chatItem.attributedText

        self.setNeedsLayout()
    }

    @IBAction func didPressReportButton(sender: UIButton)
    {
        delegate?.didPressReportButton(sender, chatItem: chatItem)
    }
}
