//
//  SplashViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/09/15.
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

import UIKit
import AVFoundation
import CWStatusBarNotification

class SplashViewController: UIViewController
{
    private var splashScreenView: SplashView
    {
        return self.view as! SplashView
    }

    @IBAction func didSwitchRememberPassword(sender: UISwitch)
    {
        self.authenticationManager.rememberPassword = sender.on
    }
    private let authenticationManager = AuthenticationManager.sharedInstance

    @IBAction func didPressRegisterAccount(sender: UIButton)
    {
        let websiteURL = NSURL(string: "http://meditation.sirimangalo.org")!
        if UIApplication.sharedApplication().canOpenURL(websiteURL) {
            UIApplication.sharedApplication().openURL(websiteURL)
        }
    }

    @IBAction func didTapContentView(sender: UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .LightContent
    }

    private func attachObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplashViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SplashViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    private func detachObservers()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.clipsToBounds = true

        let loadedUser = User()
        if let username = loadedUser.readFromSecureStore()?.data?["username"] as? String {
            self.splashScreenView.usernameField.text = username
        }

        if let password = loadedUser.readFromSecureStore()?.data?["password"] as? String {
            if authenticationManager.rememberPassword {
                self.splashScreenView.passwordField.text = password
            }
        }

    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        attachObservers()

        splashScreenView.rememberPasswordSwitch.setOn(authenticationManager.rememberPassword, animated: true)
    }

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        self.splashScreenView.transitionToBlurredBackground()
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)

        detachObservers()
        view.endEditing(true)
    }

    // MARK: Keyboard handling

    func keyboardWillShow(notification: NSNotification)
    {
        let userInfo              = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve        = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!
        let duration              = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!

        let centerY: CGFloat = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetHeight(keyboardFrame)) / 2.0
        let offset: CGFloat  = self.splashScreenView.passwordField.center.y - centerY

        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: {
            () -> Void in
            self.splashScreenView.scrollView.contentOffset = CGPointMake(0, offset)
        }, completion: nil)
    }

    func keyboardWillHide(notification: NSNotification)
    {
        let userInfo       = notification.userInfo!
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!
        let duration       = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!

        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)), animations: {
            () -> Void in
            self.splashScreenView.scrollView.contentOffset = CGPointZero
        }, completion: nil)
    }

    // MARK: Actions

    @IBAction func didPressLoginButton(sender: UIButton)
    {
        sender.enabled = false

        if (self.validate()) {
            guard let username = self.splashScreenView.usernameField.text, password = self.splashScreenView.passwordField.text else {
                return
            }

            self.authenticationManager.loginWithUsername(username, password: password, failure: {
                (error, errorString) -> Void in
                NotificationManager.displayNotification((errorString ?? NSLocalizedString("authentication.unknown.error", comment: "")) as String)

                sender.enabled = true
            }, completion: {
                (user) -> Void in
                sender.enabled = true
                self.navigatoToMainViewController()
            })

        } else {
            sender.enabled = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.splashScreenView.shake()
        }
    }

    func navigatoToMainViewController()
    {
        let tabBarController = TabBarController()
        self.navigationController?.setViewControllers([tabBarController], animated: true)
    }

    func validate() -> Bool
    {
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
