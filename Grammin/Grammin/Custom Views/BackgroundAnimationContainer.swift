//
//  BackgroundAnimationContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 4/26/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//TODO SceneKit could be a cool future feature

class BackgroundAnimationContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var viewsToAnimate : [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        beginAnimation()
    }
    
    //Public, or will just animate at init?
    fileprivate func beginAnimation() {
        for i in 0...1000 { //create 1K views randomly positioned on screen
            Logger.log("\(i)")
            //TODO random x y + dimensions
            //Add to subview
        }
        
        //Animations (CABasic or UIView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Logger.log(" --- Destroyed \(self)")
    }
}
