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
        return 0.6
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView()!
        containerView.backgroundColor = UIColor.whiteColor()
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromViewController.view!
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toViewController.view!
        
        let yTranslation = UIScreen.mainScreen().bounds.height * 0.33
        
        containerView.addSubview(toView)
        
        // From View
        let initialFrame = transitionContext.initialFrameForViewController(fromViewController)
        fromView.frame = initialFrame
        
        // Overlay view
        let overlayView = UIView(frame: initialFrame)
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, belowSubview: toView)
        
        // To View
        toView.frame = initialFrame
        toView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(0, yTranslation))
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .CurveEaseInOut, animations:
            {
                toView.transform = CGAffineTransformIdentity
                fromView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(0, yTranslation))
                overlayView.alpha = 0.6
                
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