//
//  MPSplashViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPSplashViewController: UIViewController {
    private var splashScreenView: MPSplashView { return self.view as! MPSplashView }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.splashScreenView.transitionToBlurredBackground()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    @IBAction func didPressLoginButton(sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setViewControllers([MPHomeViewController(nibName: "MPHomeViewController", bundle: nil)], animated: true)
    }
}
