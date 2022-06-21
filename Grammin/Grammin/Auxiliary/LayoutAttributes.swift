//
//  LayoutAttributes.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class LayoutAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    var angle : CGFloat = 0 {
        didSet {
            zIndex = Int(angle * 1000000)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copiedAttributes : LayoutAttributes = super.copy(with: zone) as! LayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}
