//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorListViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
