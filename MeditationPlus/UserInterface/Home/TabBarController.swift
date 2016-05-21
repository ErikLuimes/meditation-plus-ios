//
//  TabBarController.swift
//  MeditationPlus
//
//  Created by Erik Luimes 24/10/15
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

import Foundation
import UIKit

class TabBarController: UITabBarController
{
    private var tabBarTransition: TabBarTransition!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = "Meditation+"
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        tabBarTransition = TabBarTransition()
        
        let viewControllers: [UIViewController] = [
            MeditatorListViewController(nib: R.nib.meditatorListView),
            ChatViewController(),
            DhammaViewController(nib: R.nib.dhammaView),
            QuoteViewController(nib: R.nib.quoteView)
        ]
        
        for viewController in viewControllers {
            viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        setViewControllers(viewControllers, animated: true)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension TabBarController: UITabBarControllerDelegate
{
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return tabBarTransition
    }
}