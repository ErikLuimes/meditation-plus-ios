//
//  MPSplashView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPSplashView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var loginView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.loginView.transform = CGAffineTransformMakeScale(0.2, 0.2)

        self.loginView.alpha = 0
        
        self.passwordField.attributedPlaceholder = NSAttributedString(string:self.passwordField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        self.passwordField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        self.passwordField.layer.borderWidth = 1
        self.passwordField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        self.usernameField.attributedPlaceholder = NSAttributedString(string:self.usernameField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.6)])
        self.usernameField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        self.usernameField.layer.borderWidth = 1
        self.usernameField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
    }
    
    func transitionToBlurredBackground() {
        self.backgroundImageView.clipsToBounds = true
        UIView.transitionWithView(self.backgroundImageView, duration: 0.75, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundImageView.image = UIImage(named: "background_blurred")
            self.backgroundImageView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        }, completion: nil)
        
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 9.8, options: nil, animations: { () -> Void in
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
    
}
