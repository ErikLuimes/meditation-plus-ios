//
//  MPHomeViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import PageMenu
import KGFloatingDrawer
import UIImage_Additions

class MPHomeViewController: UIViewController {
    var pageMenu : CAPSPageMenu?
    
//    private var meditatorViewController: MPMeditatorListViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Meditation+"
        
        self.view.clipsToBounds = true
        
//        UINavigationBar.appearance().setBackgroundImage(
//            UIImage(),
//            forBarPosition: .Any,
//            barMetrics: .Default)
//
//        UINavigationBar.appearance().shadowImage = UIImage()
//
//        self.navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
//        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.translucent = false
////        self.navigationController?.navigationBar.shadowImage = UIImage()
//        //self.navigationController?.hidesBarsOnSwipe             = true
//        //self.navigationController?.hidesBarsOnTap               = true
//        //self.navigationController?.hidesBarsWhenKeyboardAppears = true
//
////        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.add_imageNamed("menu_btn", tintColor: UIColor.magentaColor(), style: ADDImageTintStyleKeepingAlpha), style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.add_imageNamed("user_icon", tintColor: UIColor.magentaColor(), style: ADDImageTintStyleKeepingAlpha), style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "didPressSelectMeditation:")
        
        
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let meditatorController : MPMeditatorListViewController = MPMeditatorListViewController(nibName: "MPMeditatorListViewController", bundle: nil)
        meditatorController.title = "Meditators"
//        self.meditatorViewController = meditatorController
        
//        let chatController : UIViewController = MPChatViewController(nibName: "MPChatViewController", bundle: nil)
//        let chatController : UIViewController = MPChatViewController()
//        chatController.title = "Chat"
        
//        let commitController : UIViewController = MPCommitViewController(nibName: "MPCommitViewController", bundle: nil)
//        commitController.title = "Commit"
        
        controllerArray.append(meditatorController)
//        controllerArray.append(chatController)
//        controllerArray.append(commitController)
        // AED284
        //            .ScrollMenuBackgroundColor(UIColor(red: 0xae / 255.0, green: 0xd2 / 255.0, blue: 0x84 / 255.0, alpha: 1.0))

        var xAED284 = UIColor(red: 0xae / 255.0, green: 0xd2 / 255.0, blue: 0x84 / 255.0, alpha: 1.0)
        var x80AC9C = UIColor(red: 0x80 / 255.0, green: 0xAC / 255.0, blue: 0x9C / 255.0, alpha: 1.0)
        var parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(x80AC9C),
            CAPSPageMenuOption.AddBottomMenuHairline(true),
            CAPSPageMenuOption.BottomMenuHairlineColor(x80AC9C),
            CAPSPageMenuOption.SelectedMenuItemLabelColor(x80AC9C)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Actions
    
    func didPressMenuButton(sender: UIBarButtonItem) {
        self.drawerViewController?.toggleDrawer(.Left, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
    }
    
//    func didPressSelectMeditation(sender: UIBarButtonItem) {
//        self.meditatorViewController.toggleSelectionView()
//    }
    
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
