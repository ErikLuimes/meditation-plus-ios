//
//  MPOtherMessageCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPOtherMessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithChatItem(chatItem: MPChatItem) {
        var dateFormatter       = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            
        self.messageLabel.text = chatItem.message
        self.authorLabel.text  = chatItem.username
        
        if chatItem.time != nil {
            self.dateLabel.text    = dateFormatter.stringFromDate(chatItem.time!)
        }
        
        self.avatarImageView.setImageWithURL(NSURL(string: "http://randomimage.setgetgo.com/get.php?height=400&width=400")!)
        
        self.setNeedsLayout()
    }
    
}
