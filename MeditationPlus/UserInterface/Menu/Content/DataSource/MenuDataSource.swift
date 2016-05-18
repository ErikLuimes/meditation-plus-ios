//
//  MenuDataSource.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 19/09/15
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

import Foundation
import UIKit

class MenuDataSource: NSObject, UITableViewDataSource
{
    private let cellReuseIdentifier: String

    var cellConfigurationHandler: ((MenuCell, MenuItem) -> ())?

    private var sections: [TableViewSection<MenuItem>] = [TableViewSection < MenuItem>]()

    required init(cellReuseIdentifier: String)
    {
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var numberOfRows: Int = 0

        if let items = self.sections[safe: section]?.items {
            numberOfRows = items.count
        }

        return numberOfRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier, forIndexPath: indexPath) as! MenuCell

        if let menuItem = self.itemForIndexPath(indexPath) {
            self.cellConfigurationHandler?(cell, menuItem)
        }

        return cell
    }

    // MARK: Data retrieval

    func itemForIndexPath(indexPath: NSIndexPath) -> MenuItem?
    {
        return self.sections[safe: indexPath.section]?.items[safe: indexPath.row]
    }

    func updateSections(sections: [TableViewSection<MenuItem>])
    {
        self.sections = sections
    }
}
