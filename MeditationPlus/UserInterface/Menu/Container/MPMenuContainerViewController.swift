//
//  MPMenuContainerViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 19/09/15.
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

import Foundation
import KGFloatingDrawer

class MPMenuContainerViewController: KGDrawerViewController
{
    var toggleMenuHandler: (() -> Void)!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Handler to open and close the menu drawer, will be passed to navigation controllers
        self.toggleMenuHandler = {() -> Void in
            self.toggleDrawer(.Left, animated: true, complete: { (finished) -> Void in
                
            })
        }

        self.animator.springDamping = 1

        // Menu view controller
        let menuViewController = MPMenuViewController(nibName: "MPMenuViewController", bundle: nil)
        menuViewController.drawerNavigationHandler = {(viewController: UIViewController, animated: Bool) in
            let navigationViewController = MPNavigationController(rootViewController: viewController)
            navigationViewController.toggleDrawerHandler = self.toggleMenuHandler
            
            self.centerViewController = navigationViewController
            self.closeDrawer(.Left, animated: animated, complete: { (finished) -> Void in
                
            })
        }

        // Initial view controller
        let initialContentViewController = MPSplashViewController(nibName: "MPSplashViewController", bundle: nil)
        let navigationViewController     = MPNavigationController(rootViewController: initialContentViewController)
        navigationViewController.toggleDrawerHandler = self.toggleMenuHandler

        self.centerViewController = navigationViewController
        self.leftViewController   = menuViewController
        self.backgroundImage      = UIImage(named: "background_blurred")
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}

