//
//  MPHomeViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPHomeViewController: UIViewController {
    var pageMenu : CAPSPageMenu?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Meditation+"
        
        self.navigationController?.navigationBar.translucent    = false
        self.navigationController?.hidesBarsOnSwipe             = true
        self.navigationController?.hidesBarsOnTap               = true
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let meditatorController : UIViewController = MPMeditatorListViewController(nibName: "MPMeditatorListViewController", bundle: nil)
        meditatorController.title = "Meditators"
        
        let chatController : UIViewController = MPChatViewController(nibName: "MPChatViewController", bundle: nil)
        chatController.title = "Chat"
        
        let commitController : UIViewController = MPCommitViewController(nibName: "MPCommitViewController", bundle: nil)
        commitController.title = "Commit"
        
        controllerArray.append(meditatorController)
        controllerArray.append(chatController)
        controllerArray.append(commitController)
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0, self.view.frame.width, self.view.frame.height), pageMenuOptions: nil)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
    }
    
    // MARK: Actions
    
    func didPressMenuButton(sender: UIBarButtonItem) {
        self.drawerViewController?.toggleDrawer(.Left, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
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
