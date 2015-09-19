//
//  MTMenuView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
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

import UIKit

class MPMenuView: UIView
{
    @IBOutlet weak var menuTableView: UITableView!

    @IBOutlet weak var blurView: UIVisualEffectView!
    {
        didSet
        {
            blurView.layer.cornerRadius = 10
            blurView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var cutoutImageView: UIImageView!
    {
        didSet
        {
            // Setting the rendering mode on the image is to make it work on a UIVibranceyEffectView
            cutoutImageView.image = UIImage(named: "buddha")?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }

    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.menuTableView.tableFooterView = UIView(frame: CGRectZero)
        self.menuTableView.bounces = false
        self.menuTableView.registerNib(UINib(nibName: "MPMenuCell", bundle: nil), forCellReuseIdentifier: "menuCellIdentifier")
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()

        let tableViewHeight        = CGRectGetHeight(self.menuTableView.frame)
        let tableViewContentHeight = self.menuTableView.contentSize.height

        if tableViewContentHeight < tableViewHeight {
            self.menuTableView.contentInset = UIEdgeInsetsMake((tableViewHeight - tableViewContentHeight) / 2, 0, 0, 0)
        }
    }
}
