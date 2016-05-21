//
//  TabBarTransition.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 10/05/16.
//
//  The MIT License
//  Copyright (c) 2016 Maya Interactive. All rights reserved.
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
        let overlayView = UIVisualEffectView(frame: initialFrame)
        overlayView.effect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        containerView.insertSubview(overlayView, belowSubview: fromView)
        
        // To View
        toView.frame = initialFrame
        toView.layer.transform = CATransform3DTranslate(transform, 0, 0, -100)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations:
        {
            toView.transform = CGAffineTransformIdentity
            fromView.layer.transform = CATransform3DTranslate(transform, 0, yTranslation, 0)
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