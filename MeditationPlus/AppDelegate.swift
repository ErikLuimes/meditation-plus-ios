//
//  AppDelegate.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = self.prepareDrawerViewController()
        
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func prepareDrawerViewController() -> KGDrawerViewController {
        let drawerViewController = KGDrawerViewController()
        drawerViewController.animator.springDamping = 1
        
        let initialContentViewController = MPHomeViewController(nibName: "MPHomeViewController", bundle: nil)
        let menuViewController = MPMenuViewController(nibName: "MPMenuViewController", bundle: nil)
        
        drawerViewController.centerViewController = UINavigationController(rootViewController: initialContentViewController)
        drawerViewController.leftViewController   = menuViewController
        drawerViewController.backgroundImage      = UIImage(named: "background")
        
        drawerViewController.openDrawer(KGDrawerSide.Right, animated: false) { (finished) -> Void in
                //
        }
        
        drawerViewController.closeDrawer(KGDrawerSide.Right, animated: true, complete: { (finished) -> Void in
            //
        })
        
        return drawerViewController
    }
}

