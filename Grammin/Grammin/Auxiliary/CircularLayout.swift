//
//  CircularLayout.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class CircularLayout: UICollectionViewLayout {
    
    //radius is from bottom of top item to top of bottom item
    var radius : CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }

    //adjusts width (TODO update per device)
    let itemSize = CGSize(width: 250, height: 300)
    
    var anglePerItem : CGFloat {
        return atan(itemSize.width / radius)
    }
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ?
            -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width -
            collectionView!.bounds.width)
    }
    
    //array of attributes (obviously)
    var attributesList = [LayoutAttributes]()
    
    //Used to be func, now var
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width, height: collectionView!.bounds.width)
    }
    
    override class var layoutAttributesClass: AnyClass {
        return LayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        let itemCount = self.collectionView?.numberOfItems(inSection: 0)
        if itemCount == 0 {
            return
        }
        
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2.0
        
        //anchor point
        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
        
        let theta = atan2(collectionView!.bounds.width / 2.0,
                          radius + (itemSize.height / 2.0) - (collectionView!.bounds.width / 2.0))

        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1

        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }

        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))

        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        
        attributesList = (startIndex...endIndex).map { (i)
            -> LayoutAttributes in

            let attributes = LayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
            
            attributes.size = self.itemSize
            attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)

            return attributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //NOTE: Swift/ContiguousArrayBuffer.swift:575: Fatal error: Index out of range
        return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
