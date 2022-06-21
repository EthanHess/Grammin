//
//  StoryView.swift
//  Grammin
//
//  Created by Ethan Hess on 1/2/19.
//  Copyright © 2019 EthanHess. All rights reserved.
//

import UIKit

class StoryView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var isFlipped : Bool? = nil {
        didSet {
            resetViewForFlip()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let theColor = Colors().neptuneBlue
        backgroundColor = theColor.withAlphaComponent(0.5)
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        self.isFlipped = false
    }
    
    fileprivate func resetViewForFlip() {
        if isFlipped == true {
            backgroundColor = Colors().coolGreen
            
        } else {
            backgroundColor = Colors().neptuneBlue
            
            //TODO imp. rest
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
