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
    
    private func attachObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func detachObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.clipsToBounds = true
        
        let loadedUser = MPUser()
        if let username = loadedUser.readFromSecureStore()?.data?["username"] as? String {
            self.splashScreenView.usernameField.text = username
        }
        
        if let password = loadedUser.readFromSecureStore()?.data?["password"] as? String {
            self.splashScreenView.passwordField.text = password
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        attachObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.splashScreenView.transitionToBlurredBackground()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        detachObservers()
        view.endEditing(true)
    }
    
    // MARK: Keyboard handling

    func keyboardWillShow(notification: NSNotification) {
        let userInfo              = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve        = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!
        let duration              = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!

        let centerY: CGFloat = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetHeight(keyboardFrame)) / 2.0
        let offset: CGFloat  = self.splashScreenView.passwordField.center.y - centerY
        
        var contentInset = UIEdgeInsetsZero
        if offset < 0 {
            contentInset = UIEdgeInsetsMake(0, 0 ,abs(offset) ,0)
        } else if offset > 0 {
            contentInset = UIEdgeInsetsMake(offset, 0 ,0 ,0)
        }
        
        NSLog("contentInset \(contentInset)")
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: { () -> Void in
            self.splashScreenView.scrollView.contentOffset = CGPointMake(0, offset)
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo              = notification.userInfo!
        let animationCurve        = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!
        let duration              = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!

        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: { () -> Void in
            self.splashScreenView.scrollView.contentOffset = CGPointZero
        }, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func didPressLoginButton(sender: UIButton) {
        sender.enabled = false
        
        if (self.validate()) {
            guard let username = self.splashScreenView.usernameField.text, password = self.splashScreenView.passwordField.text else {
                return
            }
            
            
            self.authenticationManager.loginWithUsername(username, password: password, failure: { (error) -> Void in
                if let errorResponse = error {
                    NSLog("error:Description: \(errorResponse.localizedDescription)")
                }
                sender.enabled = true
            }, completion: { (user) -> Void in
                sender.enabled = true
                NSLog("Logged in")
                self.navigatoToMainViewController()
//                self.navigationController?.setViewControllers([MPHomeViewController(nibName: "MPHomeViewController", bundle: nil)], animated: true)
            })
            
        } else {
            sender.enabled = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.splashScreenView.shake()
            
        }
    }
    
    func navigatoToMainViewController()
    {
        let tabBarController = MPTabBarController()
        self.navigationController?.setViewControllers([tabBarController], animated: true)
    }
    
    func validate() -> Bool {
        var isValid = true
        
        guard let username = self.splashScreenView.usernameField.text, password = self.splashScreenView.passwordField.text else {
            isValid = false
            return isValid
        }
        
        if username.characters.count == 0 || password.characters.count == 0 {
            isValid = false
        }
        
        return isValid
    }
}
