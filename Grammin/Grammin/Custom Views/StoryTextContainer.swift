//
//  StoryTextContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 4/24/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import FontAwesome_swift

class StoryTextContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Font awesome
    let boldControlView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let sizeControlView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let backgroundControlView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        perform(#selector(viewSetup), with: nil, afterDelay: 0.5)
    }
    
    @objc fileprivate func viewSetup() {
    
        let height = frame.size.height - 40
        let width = frame.size.width
        let firstFrame = CGRect(x: 20, y: 20, width: height, height: height)
        let secondFrame = CGRect(x: (width / 2) - (height / 2), y: 20, width: height, height: height)
        let thirdFrame = CGRect(x: width - (height + 20), y: 20, width: height, height: height)
        
        boldControlView.frame = firstFrame
        sizeControlView.frame = secondFrame
        backgroundControlView.frame = thirdFrame
        
        //TODO colors for theme?
        boldControlView.image = UIImage.fontAwesomeIcon(name: .arrowCircleDown, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        sizeControlView.image = UIImage.fontAwesomeIcon(name: .sketch, style: .brands, textColor: .white, size: CGSize(width: 40, height: 40))
        backgroundControlView.image = UIImage.fontAwesomeIcon(name: .brush, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        
        viewStylizer(theView: boldControlView, radius: boldControlView.frame.size.width / 2, backgroundColor: .clear)
        viewStylizer(theView: sizeControlView, radius: sizeControlView.frame.size.width / 2, backgroundColor: .clear)
        viewStylizer(theView: backgroundControlView, radius: backgroundControlView.frame.size.width / 2, backgroundColor: .clear)
        
        self.addSubview(boldControlView)
        self.addSubview(sizeControlView)
        self.addSubview(backgroundControlView)
        
        tapGestureConfig()
    }
    
    fileprivate func tapGestureConfig() {
        //TODO imp. UITG
    }
    
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
