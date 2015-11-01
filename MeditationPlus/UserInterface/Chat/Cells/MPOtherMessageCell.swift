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


    lazy var emoticonsContained: [String:String] = {
        return [
                ":)": "emoticon_00100_smile",
                ":(": "emoticon_00101_sadsmile",
                ":D": "emoticon_00102_bigsmile",
                "8-)": "emoticon_00103_cool",
                ":o": "emoticon_00105_wink",
                ";(": "emoticon_00106_crying",
                "(sweat)": "emoticon_00107_sweating",
                ":|": "emoticon_00108_speechless",
                ":*": "emoticon_00109_kiss",
                ":P": "emoticon_00110_tongueout",
                "(blush)": "emoticon_00111_blush",
                ":^)": "emoticon_00112_wondering",
                "|-)": "emoticon_00113_sleepy",
                "|(": "emoticon_00114_dull",
                "(inlove)": "emoticon_00115_inlove",
                "]:)": "emoticon_00116_evilgrin",
                "(talk)": "emoticon_00117_talking",
                "(yawn)": "emoticon_00118_yawn",
                "(puke)": "emoticon_00119_puke",
                "(doh)": "emoticon_00120_doh",
                ":@": "emoticon_00121_angry",
                "(wasntme)": "emoticon_00122_itwasntme",
                "(party)": "emoticon_00123_party",
                ":S": "emoticon_00124_worried",
                "(mm)": "emoticon_00125_mmm",
                "8-|": "emoticon_00126_nerd",
                ":x": "emoticon_00127_lipssealed",
                "(hi)": "emoticon_00128_hi",
                "(call)": "emoticon_00129_call",
                "(devil)": "emoticon_00130_devil",
                "(angel)": "emoticon_00131_angel",
                "(envy)": "emoticon_00132_envy",
                "(wait)": "emoticon_00133_wait",
                "(makeup)": "emoticon_00135_makeup",
                "(giggle)": "emoticon_00136_giggle",
                "(clap)": "emoticon_00137_clapping",
                "(think)": "emoticon_00138_thinking",
                "(rofl)": "emoticon_00140_rofl",
                "(whew)": "emoticon_00141_whew",
                "(happy)": "emoticon_00142_happy",
                "(smirk)": "emoticon_00143_smirk",
                "(nod)": "emoticon_00144_nod",
                "(shake)": "emoticon_00145_shake",
                "(punch)": "emoticon_00146_punch",
                "(emo)": "emoticon_00147_emo",
                "(highfive)": "highfive",
                "(facepalm)": "facepalm",
                "(fingers)": "fingerscrossed",
                "(lalala)": "lalala",
                "(waiting)": "waiting",
                "(headbang)": "emoticon_00179_headbang",
                "(fubar)": "emoticon_00181_fubar",
                "(swear)": "emoticon_00183_swear",
                "(tmi)": "emoticon_00184_tmi",
                "(rock)": "emoticon_00178_rock",
                "(peace)": "emoticon_peace",
                "(bow)": "emoticon_00139_bow",
                "(bear)": "emoticon_00134_bear",
                "(y)": "emoticon_00148_yes",
                "(n)": "emoticon_00149_no",
                "(handshake)": "emoticon_00150_handshake",
                "(h)": "emoticon_00152_heart",
                "(u)": "emoticon_00153_brokenheart",
                "(e)": "emoticon_00154_mail",
                "(f)": "emoticon_00155_flower",
                "(rain)": "emoticon_00156_rain",
                "(sun)": "emoticon_00157_sun",
                "(o)": "emoticon_00158_time",
                "(music)": "emoticon_00159_music",
                "(~)": "emoticon_00160_movie",
                "(mp)": "emoticon_00161_phone",
                "(coffee)": "emoticon_00162_coffee",
                "(pizza)": "emoticon_00163_pizza",
                "(cash)": "emoticon_00164_cash",
                "(muscle)": "emoticon_00165_muscle",
                "(^)": "emoticon_00166_cake",
                "(d)": "emoticon_00168_drink",
                "(dance)": "emoticon_00169_dance",
                "(ninja)": "emoticon_00170_ninja",
                "(*)": "emoticon_00171_star",
                "(toivo)": "emoticon_00177_toivo",
                "(bug)": "emoticon_00180_bug",
                "(poolparty)": "emoticon_00182_poolparty",
                "(heidy)": "emoticon_00185_heidy",
                "(tumbleweed)": "tumbleweed",
                "(wfh)": "wfh"
        ]
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithChatItem(chatItem: MPChatItem) {
        let dateFormatter       = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
//        let regExp = try! NSRegularExpression(pattern: "\\(.*\\)", options: [])
//        let regExp = try! NSRegularExpression(pattern:"\\(.*\\)|:\\)|:\\)|:\(|:D|8-\\)|:o|;\\(|:\||:\*|:P|:\^\\)|\|-\\)|\|\\(|\]:\\)|:@|:S|8-\||:x", options: [])
        let regExp = try! NSRegularExpression(pattern:"\\(.*\\)|:\\)|:\\(|:D|8-\\)|:o|;\\(|:\\||:\\*|:P|:\\^\\)|\\|-\\)|\\|\\(|\\]:\\)|:@|:S|8-\\||:x", options: [])
        
        
        if let message = chatItem.message {
            var attributedMessage = NSMutableAttributedString(string: message)
            var matches           = regExp.matchesInString(message, options: NSMatchingOptions(), range: NSMakeRange(0, message.characters.count))
            
            for result: NSTextCheckingResult in matches.reverse() {
                let match = (message as NSString).substringWithRange(result.range)
                let textAttachment = NSTextAttachment()
                if let imageName = self.emoticonsContained[match] {
                    textAttachment.image = UIImage(named: imageName)
                }
                
                let replacementForTemplate = NSAttributedString(attachment: textAttachment)
                attributedMessage.replaceCharactersInRange(result.range, withAttributedString: replacementForTemplate)
                
                messageLabel.attributedText = attributedMessage

            }
            
//            let font = messageLabel.font
//            let modified = NSString(format:"<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>", message) as String

            
//            let attrStr = try? NSAttributedString(
//            data: modified.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
//            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
//            documentAttributes: nil)
            

//            messageLabel.attributedText = attrStr
        }

//        self.authorLabel.text  = "\(chatItem.username) - \u{0001F604}"
        authorLabel.text  = (chatItem.username)

        if chatItem.time != nil {
            self.dateLabel.text = dateFormatter.stringFromDate(chatItem.time!)
        }
        
        self.avatarImageView.sd_setImageWithURL(NSURL(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")!)
        
        self.setNeedsLayout()
    }

    func meh() {

    }
    
}
