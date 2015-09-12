//
//  MPMenuViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import KGFloatingDrawer

private class MPMenuItem {
    private(set) var name: String!
    
    private(set) var navigationBlock: (()->Void)?
    
    required init(name: String, _ navigationBlock: (() -> Void)? = nil) {
        self.name            = name
        self.navigationBlock = navigationBlock
    }
}

class MPMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var menuItems: [MPMenuItem] = [MPMenuItem]()
    private var menuView: MPMenuView { return self.view as! MPMenuView }
    private let menuCellIdentifier = "menuCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let homeItem = MPMenuItem(name: "Home") {
            NSLog("home")
        }
        self.menuItems.append(homeItem)
        
        let settingsItem = MPMenuItem(name: "Settings") {
            NSLog("settings")
        }
        self.menuItems.append(settingsItem)
        
        let aboutItem = MPMenuItem(name: "About") {
            NSLog("about")
        }
        self.menuItems.append(aboutItem)
        
        let logoutItem = MPMenuItem(name: "Logout") {
            MTAuthenticationManager.sharedInstance.logout()
            self.drawerViewController?.centerViewController = UINavigationController(rootViewController: MPSplashViewController(nibName: "MPSplashViewController", bundle: nil))
            
            self.drawerViewController?.closeDrawer(.Left, animated: false, complete: { (finished) -> Void in
                //
            })
            
            NSLog("logout pressed")
        }
        self.menuItems.append(logoutItem)
        
        self.menuView.menuTableView.delegate   = self
        self.menuView.menuTableView.dataSource = self
        self.menuView.menuTableView.registerNib(UINib(nibName: "MPMenuCell", bundle: nil), forCellReuseIdentifier: self.menuCellIdentifier)
        self.menuView.menuTableView.tableFooterView = UIView(frame: CGRectZero)
        self.menuView.menuTableView.bounces         = false
    }

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell             = tableView.dequeueReusableCellWithIdentifier(self.menuCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.menuItems[indexPath.row].name
        
        return cell
    }
    
    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.menuItems[indexPath.row].navigationBlock?()
    }
    
    var drawerViewController: KGDrawerViewController? {
        var parentViewController = self.parentViewController
        
        while parentViewController != nil &&  !(parentViewController is KGDrawerViewController) {
            parentViewController = parentViewController?.parentViewController
        }
        
        if (parentViewController is KGDrawerViewController) {
            return parentViewController as? KGDrawerViewController
        }
        
        return nil
    }
}
