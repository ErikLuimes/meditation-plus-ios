//
//  MPSplashView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/09/15.
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

import UIKit

protocol MPSplashViewDelegate: NSObjectProtocol {
    func splashViewPerformLogin(splashView: MPSplashView)
}

class MPSplashView: UIView, UITextFieldDelegate {
    weak var delegate: MPSplashViewDelegate?

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var rememberPasswordSwitch: UISwitch!

    @IBOutlet weak var loginView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.loginView.transform = CGAffineTransformMakeScale(0.2, 0.2)

        self.loginView.alpha = 0
        
        self.passwordField.attributedPlaceholder = NSAttributedString(string:self.passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        self.passwordField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        self.passwordField.layer.borderWidth = 1
        self.passwordField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        passwordField.leftViewMode = .Always
        let passwordImageView         = UIImageView(frame: CGRectMake(0, 0, 32, CGRectGetHeight(passwordField.frame)))
        passwordImageView.image       = UIImage(named: "pass_icon")
        passwordImageView.contentMode = .Center
        passwordField.leftView        = passwordImageView
        
        passwordField.delegate = self
        
        self.usernameField.attributedPlaceholder = NSAttributedString(string:self.usernameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        self.usernameField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        self.usernameField.layer.borderWidth = 1
        self.usernameField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        usernameField.leftViewMode = .Always
        let usernameImageView         = UIImageView(frame: CGRectMake(0, 0, 32, CGRectGetHeight(usernameField.frame)))
        usernameImageView.image       = UIImage(named: "user_icon")
        usernameImageView.contentMode = .Center
        usernameField.leftView        = usernameImageView
        
        usernameField.delegate = self
    }
    
    func transitionToBlurredBackground() {
        self.backgroundImageView.clipsToBounds = true
        UIView.transitionWithView(self.backgroundImageView, duration: 0.75, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundImageView.image = UIImage(named: "background_blurred")
            self.backgroundImageView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        }, completion: nil)
        
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 9.8, options: [], animations: { () -> Void in
            self.loginView.alpha = 1
            self.loginView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    func shake() {
        let shakeAnimation = CAKeyframeAnimation( keyPath:"transform" )
        
        shakeAnimation.values = [
            NSValue( CATransform3D:CATransform3DMakeTranslation(-15, 0, 0 ) ),
            NSValue( CATransform3D:CATransform3DMakeTranslation( 15, 0, 0 ) )
        ]
        
        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount  = 2
        shakeAnimation.duration     = 0.07
        
        self.loginView.layer.addAnimation(shakeAnimation, forKey: "shakeAnimation")
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            delegate?.splashViewPerformLogin(self)
        }
        
        return false
    }
}
