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
        self.window?.rootViewController = self.drawerViewController
        
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    var drawerViewController: KGDrawerViewController {
        let drawerViewController = KGDrawerViewController()
        drawerViewController.animator.springDamping = 1
        
        let initialContentViewController = MPHomeViewController(nibName: "MPHomeViewController", bundle: nil)
        let menuViewController = MPMenuViewController(nibName: "MPMenuViewController", bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: initialContentViewController)
        navigationController.pushViewController(MPSplashViewController(nibName: "MPSplashViewController", bundle: nil), animated: false)
        
//        drawerViewController.centerViewController = UINavigationController(rootViewController: initialContentViewController)
        drawerViewController.centerViewController = navigationController
        drawerViewController.leftViewController   = menuViewController
        drawerViewController.backgroundImage      = UIImage(named: "background_blurred")
        
        return drawerViewController
    }
    
}


