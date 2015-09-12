//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

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
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(MPMeditatorDataSource.MPMeditatorCellIdentifier) as! UITableViewCell

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