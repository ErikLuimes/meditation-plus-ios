//
//  MPSplashViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import AVFoundation

class MPSplashViewController: UIViewController {
    private var splashScreenView: MPSplashView { return self.view as! MPSplashView }
    
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.clipsToBounds = true
        
        self.splashScreenView.usernameField.text = self.authenticationManager.username
        self.splashScreenView.passwordField.text = self.authenticationManager.password
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.splashScreenView.transitionToBlurredBackground()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    @IBAction func didPressLoginButton(sender: UIButton) {
        sender.enabled = false
        
        if (self.validate()) {
            let username = self.splashScreenView.usernameField.text
            let password = self.splashScreenView.passwordField.text
            
            self.authenticationManager.loginWithUsername(username, password: password, failure: { (error) -> Void in
                if let errorResponse = error {
                    NSLog("error:Description: \(errorResponse.localizedDescription)")
                }
                sender.enabled = true
            }, completion: { (user) -> Void in
                sender.enabled = true
                NSLog("Logged in")
//                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.setViewControllers([MPHomeViewController(nibName: "MPHomeViewController", bundle: nil)], animated: true)
            })
            
        } else {
            sender.enabled = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.splashScreenView.shake()
            
        }
    }
    
    func validate() -> Bool {
        var isValid = true
        
        if count(self.splashScreenView.usernameField.text) == 0 || count(self.splashScreenView.passwordField.text) == 0 {
            isValid = false
        }
        
        return isValid
    }
}
