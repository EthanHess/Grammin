//
//  CustomPresenter.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit


class CustomPresenter: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
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
        
        let xCoord = -toView.frame.width
        let yCoord = 0
        let theWidth = toView.frame.width
        let theHeight = toView.frame.height
        
        let startFrame = CGRect(x: xCoord, y: CGFloat(yCoord), width: theWidth, height: theHeight)
        toView.frame = startFrame
        
        //Try 1 second, 0.5 may work better though
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            toView.frame = CGRect(x: 0, y: 0, width: theWidth, height: theHeight)
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (complete) in
            transitionContext.completeTransition(true)
        }
    }
}
