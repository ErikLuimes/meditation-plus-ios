//
//  SplashView.swift
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

protocol SplashViewDelegate: NSObjectProtocol
{
    func splashViewPerformLogin(splashView: SplashView)
}

class SplashView: UIView, UITextFieldDelegate
{
    weak var delegate: SplashViewDelegate?

    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var rememberPasswordSwitch: UISwitch!

    @IBOutlet weak var loginView: UIView!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        loginView.transform = CGAffineTransformMakeScale(0.2, 0.2)
        loginView.alpha     = 0
        
        let passwordImageView         = UIImageView(frame: CGRectMake(0, 0, 32, CGRectGetHeight(passwordField.frame)))
        passwordImageView.image       = R.image.lockIcon()
        passwordImageView.contentMode = .Center

        passwordField.attributedPlaceholder = NSAttributedString(string: self.passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        passwordField.layer.borderColor     = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        passwordField.layer.borderWidth     = 1
        passwordField.backgroundColor       = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        passwordField.leftViewMode          = .Always
        passwordField.leftView              = passwordImageView
        passwordField.delegate              = self

        let usernameImageView         = UIImageView(frame: CGRectMake(0, 0, 32, CGRectGetHeight(usernameField.frame)))
        usernameImageView.image       = R.image.userIcon()
        usernameImageView.contentMode = .Center
        
        usernameField.attributedPlaceholder = NSAttributedString(string: self.usernameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        usernameField.layer.borderColor     = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        usernameField.layer.borderWidth     = 1
        usernameField.backgroundColor       = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        usernameField.leftViewMode          = .Always
        usernameField.leftView              = usernameImageView
        usernameField.delegate              = self
    }

    func transitionToBlurredBackground()
    {
        self.backgroundImageView.clipsToBounds = true
        UIView.transitionWithView(self.backgroundImageView, duration: 0.75, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            () -> Void in
            
            self.backgroundImageView.image     = R.image.backgroundBlurred()
            self.backgroundImageView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        }, completion: nil)

        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 9.8, options: [], animations: {
            () -> Void in
            
            self.loginView.alpha     = 1
            self.loginView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }

    func shake()
    {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform")

        shakeAnimation.values = [
            NSValue(CATransform3D: CATransform3DMakeTranslation(-15, 0, 0)),
            NSValue(CATransform3D: CATransform3DMakeTranslation(15, 0, 0))
        ]

        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount  = 2
        shakeAnimation.duration     = 0.07

        self.loginView.layer.addAnimation(shakeAnimation, forKey: "shakeAnimation")

    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            delegate?.splashViewPerformLogin(self)
        }

        return false
    }
}
