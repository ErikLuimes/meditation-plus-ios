//
//  MenuViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
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

class MenuViewController: UIViewController
{
    private var menuView: MenuView
    {
        return self.view as! MenuView
    }

    var drawerNavigationHandler: ((UIViewController, Bool) -> Void)?

    private var menuDataSource: MenuDataSource!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        menuDataSource = MenuDataSource()
        
        menuView.menuTableView.dataSource = menuDataSource
        menuView.menuTableView.delegate   = self
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let menuItem = self.menuDataSource.itemForIndexPath(indexPath) {
            switch menuItem {
            case .Home:
                self.drawerNavigationHandler?(TabBarController(), true)
            case .Logout:
                if MeditationTimer.sharedInstance.state != .Stopped {
                    MeditationTimer.sharedInstance.cancelTimer()
                }
                
                self.drawerNavigationHandler?(SplashViewController(nib: R.nib.splashView), false)
            }
        }
    }
}