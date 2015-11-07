//
//  MPOtherMessageCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit
import DTCoreText
import DateTools

class MPMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel:    UITextView!
    @IBOutlet weak var authorLabel:     UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel:       UILabel!

    override func prepareForReuse() {
        self.avatarImageView.image = nil
    }
    
    func configureWithChatItem(chatItem: MPChatItem) {
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
}
