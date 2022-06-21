//
//  StoryColorChoiceView.swift
//  Grammin
//
//  Created by Ethan Hess on 4/24/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//NOTE color should change both text and background?

class StoryColorChoiceView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //TODO
    
    var colorViewArray : [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 5
        
        perform(#selector(viewSetup), with: nil, afterDelay: 0.5) //For frame to set and not be Zero
    }
    
    @objc fileprivate func viewSetup() {
        let height = self.frame.size.height
        let half = height / 2
        let viewDimension = half - 20
        for i in 0...(colors().count - 1) {
            //First half (top)
            if i < 5 {
                let yCoord = CGFloat(10)
                let xCoord = CGFloat((10 * (i + 1))) + CGFloat((viewDimension * CGFloat(i)))
                let frame = CGRect(x: xCoord, y: yCoord, width: viewDimension, height: viewDimension)
                let theView = UIView(frame: frame)
                viewStylizer(theView: theView, radius: viewDimension / 2, backgroundColor: colors()[i])
                animationViewOnScreen(view: theView, duration: Double(i / 5))
            } else {
                let yCoord = CGFloat(half + 10)
                let xCoord = CGFloat((10 * ((i - 5) + 1))) + CGFloat((viewDimension * (CGFloat(i - 5))))
                let frame = CGRect(x: xCoord, y: yCoord, width: viewDimension, height: viewDimension)
                let theView = UIView(frame: frame)
                viewStylizer(theView: theView, radius: viewDimension / 2, backgroundColor: colors()[i])
                animationViewOnScreen(view: theView, duration: Double(i / 5))
            }
        }
    }
    
    //This will be called when we scroll here, not init
    fileprivate func animationViewOnScreen(view: UIView, duration: Double) {
        self.addSubview(view)
        UIView.animate(withDuration: duration) {
            view.alpha = 1
        }
    }
    
    fileprivate func viewStylizer(theView: UIView, radius: CGFloat, backgroundColor: UIColor) {
        theView.layer.masksToBounds = true
        theView.layer.cornerRadius = radius
        theView.alpha = 0
        theView.backgroundColor = backgroundColor
        theView.layer.borderColor = UIColor.gray.cgColor
        theView.layer.borderWidth = 1
    }
    
    //TODO custom
    fileprivate func colors() -> [UIColor] {
        return [.red, .blue, .black, .green, .orange, .purple, .cyan, .brown, .lightGray, .magenta]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
