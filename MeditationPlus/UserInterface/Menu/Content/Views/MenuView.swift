//
//  MTMenuView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
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
import Rswift

class MenuView: UIView
{
    @IBOutlet weak var menuTableView: UITableView!

    @IBOutlet weak var blurView: UIVisualEffectView!
    {
        didSet
        {
            blurView.layer.cornerRadius  = 10
            blurView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var cutoutImageView: UIImageView!
    {
        didSet
        {
            // Setting the rendering mode on the image is to make it work on a UIVibranceyEffectView
            cutoutImageView.image = R.image.buddha()?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }

    @IBOutlet weak var imageViewTrailingMargin: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        menuTableView.tableFooterView = UIView(frame: CGRectZero)
        menuTableView.bounces         = false
        menuTableView.registerNib(R.nib.menuCell(), forCellReuseIdentifier: R.nib.menuCell.name)

        imageViewTrailingMargin.constant = (-CGRectGetWidth(cutoutImageView.frame) / 3.0)
    }
}
