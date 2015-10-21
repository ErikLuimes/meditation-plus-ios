//
//  MPMeditatorDataSource.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
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

class MPMeditatorDataSource: NSObject, UITableViewDataSource {
    var meditators = [MPMeditator]()

    static let MPMeditatorCellIdentifier: String = "MPMeditatorCellIdentifier"

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.meditators.count == 0 ? 0 : 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.meditators.count : 0;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(MPMeditatorDataSource.MPMeditatorCellIdentifier)!

        if let meditator = self.meditatorForIndexPath(indexPath), meditatorCell = cell as? MPMeditatorCell {
            meditatorCell.configureWithMeditator(meditator)
        }

        return cell
    }

    func meditatorForIndexPath(indexPath: NSIndexPath) -> MPMeditator? {
        var meditator: MPMeditator?

        if indexPath.row < meditators.count {
            meditator = meditators[indexPath.row]
        }

        return meditator
    }

    func updateMeditators(meditators: [MPMeditator]) {
        self.meditators.removeAll()

        self.meditators += meditators
    }

}