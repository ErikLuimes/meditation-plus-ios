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
import KGFloatingDrawer

class MPMenuItem
{
    private(set) var name: String!
    var title: String { return name }

    private(set) var navigationBlock: (() -> Void)?

    required init(name: String, _ navigationBlock: (() -> Void)? = nil)
    {
        self.name = name
        self.navigationBlock = navigationBlock
    }
}

class MPMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var menuItems: [MPMenuItem] = [MPMenuItem]()
    private var menuView: MPMenuView
    {
        return self.view as! MPMenuView
    }
    private let menuCellIdentifier = "menuCellIdentifier"

    private var cellConfigurationHandler: ((MPMenuCell, MPMenuItem) -> ())!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.cellConfigurationHandler = { cell, menuItem in
            cell.viewData = MPMenuCell.ViewData(menuItem: menuItem)
        }
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad()
    {
        super.viewDidLoad()

        let homeItem = MPMenuItem(name: "Home")
        {
            NSLog("home")
        }
        self.menuItems.append(homeItem)

        let settingsItem = MPMenuItem(name: "Settings")
        {
            NSLog("settings")
        }
        self.menuItems.append(settingsItem)

        let aboutItem = MPMenuItem(name: "About")
        {
            NSLog("about")
        }
        self.menuItems.append(aboutItem)

        let logoutItem = MPMenuItem(name: "Logout")
        {
            MTAuthenticationManager.sharedInstance.logout()
            self.drawerViewController?.centerViewController = UINavigationController(rootViewController: MPSplashViewController(nibName: "MPSplashViewController", bundle: nil))

            self.drawerViewController?.closeDrawer(.Left, animated: false, complete: {
                (finished) -> Void in
                //
            })

            NSLog("logout pressed")
        }
        self.menuItems.append(logoutItem)

        self.menuView.menuTableView.delegate = self
        self.menuView.menuTableView.dataSource = self
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell
        = tableView.dequeueReusableCellWithIdentifier(self.menuCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.menuItems[indexPath.row].name

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.menuItems[indexPath.row].navigationBlock?()
    }

    // Bad
    var drawerViewController: KGDrawerViewController?
    {
        var parentViewController = self.parentViewController

        while parentViewController != nil && !(parentViewController is KGDrawerViewController) {
            parentViewController = parentViewController?.parentViewController
        }

        if (parentViewController is KGDrawerViewController) {
            return parentViewController as? KGDrawerViewController
        }

        return nil
    }
}
