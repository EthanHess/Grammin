//
//  MyProfileMediaCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/29/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class MyProfileMediaCell: UICollectionViewCell {
    
    //TODO add type sub image? Image/Video/Multi or whatever else?
    let mainImageView : PostCellImageView = {
        let iv = PostCellImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    var post : Post? {
        didSet {
            guard let postImageUrl = post?.imageURL else { return }
            mainImageView.loadImage(urlString: postImageUrl)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        uiConfig()
    }
    
    fileprivate func uiConfig() {
        addSubview(mainImageView)
        mainImageView.anchor(top: contentView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        mainImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //TODO uncomment for card deck, or move to different cell class?
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//        let circularlayoutAttributes = layoutAttributes as! LayoutAttributes
//        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
//        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
//    }
}
