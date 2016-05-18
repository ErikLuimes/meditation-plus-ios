//
//  OtherMessageCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
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
