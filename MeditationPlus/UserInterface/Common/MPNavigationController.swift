//
//  MPNavigationController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 19/09/15
//  Copyright (c) 2015 Maya Interactive
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
import UIImage_Additions

class MPNavigationController: UINavigationController, UINavigationControllerDelegate
{
    var toggleDrawerHandler: (() -> Void)?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController)
    {
        super.init(rootViewController: rootViewController)

        self.navigationBar.tintColor = UIColor.lightGrayColor()
        self.delegate                = self;
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count != 1 {
            return
        }
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.add_imageNamed("menu_btn", tintColor: UIColor.magentaColor(), style: ADDImageTintStyleKeepingAlpha), style: UIBarButtonItemStyle.Plain, target: self, action: "didPressMenuButton:")
    }

    func didPressMenuButton(sender: UIBarButtonItem) {
        self.toggleDrawerHandler?()
    }
}
