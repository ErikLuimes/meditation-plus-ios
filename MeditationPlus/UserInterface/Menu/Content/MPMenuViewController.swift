//
//  MPMenuViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
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

class MPMenuViewController: UIViewController, UITableViewDelegate
{
    private var menuView: MPMenuView { return self.view as! MPMenuView }

    var drawerNavigationHandler: ((UIViewController, Bool) -> Void)?

    private let menuCellIdentifier = "menuCellIdentifier"

    private var menuDataSource: MPMenuDataSource!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.menuDataSource = MPMenuDataSource(cellReuseIdentifier: self.menuCellIdentifier)
        self.menuDataSource.updateSections(self.menuSections())
        self.menuDataSource.cellConfigurationHandler = { cell, menuItem in
            cell.viewData = MPMenuCell.ViewData(menuItem: menuItem)
        }

        self.menuView.menuTableView.dataSource = self.menuDataSource;
        self.menuView.menuTableView.delegate   = self
        self.menuView.menuTableView.registerNib(UINib(nibName: "MPMenuCell", bundle: nil), forCellReuseIdentifier: self.menuCellIdentifier)
    }

    // MARK: Setup Menu Items

    private func menuSections() -> [MPTableViewSection<MPMenuItem>] {
        var sections: [MPTableViewSection<MPMenuItem>] = [MPTableViewSection<MPMenuItem>]()

        let toolsSection = MPTableViewSection<MPMenuItem>(title: "Tools", items: [
                MPMenuItem.Meditators,
        ])

        let informationSection = MPTableViewSection<MPMenuItem>(title: "Misc", items: [
                MPMenuItem.Logout
        ])

        sections.append(toolsSection)
        sections.append(informationSection)

        return sections;
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let menuItem = self.menuDataSource.itemForIndexPath(indexPath) {
            switch menuItem {
                case .Meditators:
                    self.drawerNavigationHandler?(MPMeditatorListViewController(nibName: "MPMeditatorListViewController", bundle: nil), true)

                case .Logout:
                    if MPMeditationTimer.sharedInstance.state != .Stopped {
                        MPMeditationTimer.sharedInstance.cancelTimer()
                    }
                    self.drawerNavigationHandler?(MPSplashViewController(nibName: "MPSplashViewController", bundle: nil), false)
                default:
                    NSLog("default")
            }
        }
    }
}
