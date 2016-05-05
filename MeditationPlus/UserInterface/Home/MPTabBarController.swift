//
//  MPTabBarController.swift
//  MeditationPlus
//
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

class MPTabBarController: UITabBarController
{
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        var viewControllers: [UIViewController] = []

        let meditatorController: MPMeditatorListViewController = MPMeditatorListViewController(nibName: "MPMeditatorListViewController", bundle: nil)
        viewControllers.append(meditatorController)

        let chatViewController: MPChatViewController = MPChatViewController()
        viewControllers.append(chatViewController)

        let dhammaViewController: MPDhammaViewController = MPDhammaViewController(nibName: "MPDhammaViewController", bundle: nil)
        viewControllers.append(dhammaViewController)

        let quoteViewController: MPQuoteViewController = MPQuoteViewController(nibName: "MPQuoteViewController", bundle: nil)
        viewControllers.append(quoteViewController)

        self.viewControllers = viewControllers

        UITabBar.appearance().tintColor = UIColor.orangeColor()

        title = "Meditation+"
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}