//  Created by Erik Luimes on 24/10/15
//  Copyright (c) 2015 Maya Interactive
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

import Foundation
import UIKit

class MPQuoteView: UIView
{
    @IBOutlet weak var quoteView: UITextView!

    @IBOutlet weak var cite: UILabel!

    @IBOutlet weak var contentWidth: NSLayoutConstraint!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        contentWidth.constant = UIScreen.mainScreen().bounds.size.width - 30
        quoteView.alpha = 0
        cite.alpha = 0
    }

    func configureWithQuote(quote: Quote)
    {
        if let quote = quote.quote {
            let font = UIFont.systemFontOfSize(16)
            let modifiedFont = NSString(format: "<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>", quote) as String

            let attrStr = try? NSAttributedString(
            data: modifiedFont.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
            documentAttributes: nil)

            quoteView.attributedText = attrStr
        }

        cite.text = quote.cite

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.quoteView.alpha = 1.0
            self.cite.alpha = 1.0
        }, completion: nil)
    }
}


