//
//  TabBarTransition.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

public class TabBarTransition: NSObject, UIViewControllerAnimatedTransitioning
{
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.55
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView()!
        containerView.backgroundColor = UIColor.whiteColor()
        
        var transform     = CATransform3DIdentity
        transform.m34 = -1.0 / 850
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromViewController.view!
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toViewController.view!
        
        let yTranslation = UIScreen.mainScreen().bounds.height
        
        containerView.insertSubview(toView, atIndex:0)
        containerView.addSubview(fromView)
        
        // From View
        let initialFrame = transitionContext.initialFrameForViewController(fromViewController)
        fromView.frame = initialFrame
        
        // Overlay view
//        let overlayView = UIView(frame: initialFrame)
        let overlayView = UIVisualEffectView(frame: initialFrame)
        overlayView.effect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//        overlayView.backgroundColor = UIColor.whiteColor()
//        overlayView.alpha = 1.0
        containerView.insertSubview(overlayView, belowSubview: fromView)
        
        // To View
        toView.frame = initialFrame
        toView.layer.transform = CATransform3DTranslate(transform, 0, 0, -100)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations:
            {
                toView.transform = CGAffineTransformIdentity
                fromView.layer.transform = CATransform3DTranslate(transform, 0, yTranslation, 0)
//                overlayView.alpha = 0.0
                overlayView.effect = nil
                
            })
        {
            (finished) in
            
            fromView.transform = CGAffineTransformIdentity
            fromView.alpha = 1.0
            overlayView.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
        
    }
    
}