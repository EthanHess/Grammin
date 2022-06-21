//
//  StoryFilterChoiceView.swift
//  Grammin
//
//  Created by Ethan Hess on 4/27/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class StoryFilterChoiceView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let filterControlOne : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let filterControlTwo : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let filterControlThree : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    //Top right, to cycle through
    let switchModeControl : UIImageView = {
        let iv = UIImageView()
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        perform(#selector(viewSetup), with: nil, afterDelay: 0.5)
    }
    
    @objc fileprivate func viewSetup() {
        let height = frame.size.height - 60
        let width = frame.size.width
        let firstFrame = CGRect(x: 30, y: 30, width: height, height: height)
        let secondFrame = CGRect(x: (width / 2) - (height / 2), y: 30, width: height, height: height)
        let thirdFrame = CGRect(x: width - (height + 30), y: 30, width: height, height: height)
        
        filterControlOne.frame = firstFrame
        filterControlTwo.frame = secondFrame
        filterControlThree.frame = thirdFrame
        
        //TODO colors for theme?
        filterControlOne.image = UIImage.fontAwesomeIcon(name: .arrowCircleDown, style: .solid, textColor: Colors().aquarium, size: CGSize(width: 40, height: 40))
        filterControlTwo.image = UIImage.fontAwesomeIcon(name: .sketch, style: .brands, textColor: Colors().limeGreen, size: CGSize(width: 40, height: 40))
        filterControlThree.image = UIImage.fontAwesomeIcon(name: .brush, style: .solid, textColor: Colors().coolPink, size: CGSize(width: 40, height: 40))
        
        viewStylizer(theView: filterControlOne, radius: filterControlOne.frame.size.width / 2, backgroundColor: .clear)
        viewStylizer(theView: filterControlTwo, radius: filterControlTwo.frame.size.width / 2, backgroundColor: .clear)
        viewStylizer(theView: filterControlThree, radius: filterControlThree.frame.size.width / 2, backgroundColor: .clear)
        
        self.addSubview(filterControlOne)
        self.addSubview(filterControlTwo)
        self.addSubview(filterControlThree)
        
        //Top right toggle view
        let switchFrame = CGRect(x: self.frame.size.width - 30, y: 10, width: 20, height: 20)
        switchModeControl.frame = switchFrame
        switchModeControl.image = UIImage.fontAwesomeIcon(name: .apple, style: .brands, textColor: Colors().coolGreen, size: CGSize(width: 20, height: 20))
        
        viewStylizer(theView: switchModeControl, radius: 10, backgroundColor: .clear)
        
        self.addSubview(switchModeControl)
        
        tapGestureConfig()
    }
    
    fileprivate func tapGestureConfig() {
        //TODO imp. UITG
    }
    
    
    //Cycle through options
    @objc fileprivate func typeChangeController() {
        
    }
    
    //TODO border colors
    fileprivate func viewStylizer(theView: UIView, radius: CGFloat, backgroundColor: UIColor) {
        theView.layer.masksToBounds = true
        theView.layer.cornerRadius = radius
        theView.backgroundColor = backgroundColor
        theView.layer.borderColor = UIColor.white.cgColor
        theView.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
