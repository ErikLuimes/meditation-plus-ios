//
//  VideoListView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/11/15.
//  Copyright (c) 2015 Maya Interactive.
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

class MPVideoListView: UIView {
    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.registerNib(UINib(nibName: "MPVideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tableView.rowHeight = (UIScreen.mainScreen().bounds.size.width / 16.0) * 9.0
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 49, right: 0)
        tableView.tableFooterView = UIView()

        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.orangeColor()
        tableView.addSubview(refreshControl)
    }
}
