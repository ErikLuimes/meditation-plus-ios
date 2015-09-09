//
//  MPMenuViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

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
    private let menuCellidentifier = "menuCellidentifier"
    
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
            NSLog("logout")
        }
        self.menuItems.append(logoutItem)
        
        self.menuView.menuTableView.delegate   = self
        self.menuView.menuTableView.dataSource = self
    }

    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell             = tableView.dequeueReusableCellWithIdentifier(self.menuCellidentifier, forIndexPath: indexPath)
        cell.textLabel?.text = self.menuItems[indexPath.row].name
        
        return cell
    }
    
    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.menuItems[indexPath.row].navigationBlock?()
    }
}
