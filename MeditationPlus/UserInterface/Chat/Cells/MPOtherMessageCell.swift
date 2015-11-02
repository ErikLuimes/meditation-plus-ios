//
//  MPOtherMessageCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit
import DTCoreText

class MPOtherMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    func configureWithChatItem(chatItem: MPChatItem) {
        let dateFormatter       = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle

        authorLabel.text  = (chatItem.username)

        if chatItem.time != nil {
            self.dateLabel.text = dateFormatter.stringFromDate(chatItem.time!)
        }
        
        self.avatarImageView.sd_setImageWithURL(NSURL(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")!)
        
        messageLabel.attributedText = chatItem.attributedText
        
        self.setNeedsLayout()
    }
}
