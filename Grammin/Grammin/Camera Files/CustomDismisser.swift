//
//  CustomDismisser.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class CustomDismisser: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1 //Maybe too long?
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else {
            Logger.log("No from view");
            return
        }
        guard let toView = transitionContext.view(forKey: .to) else {
            Logger.log("No to view");
            return
        }
        
        containerView.addSubview(toView)
        
        let fromFrame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        let toFrame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            fromView.frame = fromFrame
            toView.frame = toFrame
            
        }) { (complete) in
            transitionContext.completeTransition(true)
        }
    }
}
