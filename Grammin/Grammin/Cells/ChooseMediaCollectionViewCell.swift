//
//  ChooseMediaCollectionViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 6/17/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import AVKit //NOTE: Can maybe extract UIImage from thumbnail instead of set up AVPlayer here
import CoreGraphics

enum MediaType {
    case Image
    case Video
    case Audio
    case None
} //TODO can add audio etc.

class ChooseMediaCollectionViewCell: UICollectionViewCell {
    
    let mainImageView : UIImageView = {
        let miv = UIImageView()
        //TODO: Config
        return miv
    }()
    
    let mediaTypeImageView : UIImageView = {
        let mtiv = UIImageView()
        //TODO: Config
        return mtiv
    }()
    
    let checkmarkImage : UIImageView = {
        let cmi = UIImageView()
        cmi.image = UIImage(named: "checkmarkBlueBorder")
        return cmi
    }()
    
    var mediaType = MediaType.Image
    
    var collectionItem: CollectionItem? {
        didSet {
            if collectionItem?.media == "image" {
                self.mediaType = .Image
            } else if collectionItem?.media == "video" {
                self.mediaType = .Video
            } else {
                self.mediaType = .None
            }
            viewConfigWithType()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    fileprivate func viewConfigWithType() {
        guard let theItem = self.collectionItem else { //Can this happen?
            Logger.log("??")
            return
        }
        if self.mediaType == .None {
            //Add placeholder image here?
            return
        }
        
        self.addSubview(mainImageView)
        self.mainImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        let paddingLeftMT = self.frame.size.width - 50
        self.addSubview(mediaTypeImageView)
        self.mediaTypeImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 10, paddingLeft: paddingLeftMT, paddingBottom: 0, paddingRight: 10, width: 40, height: 40)
        
        //Have wrapper func. if we use more than once
        self.mediaTypeImageView.backgroundColor = .black
        self.mediaTypeImageView.layer.borderWidth = 1
        self.mediaTypeImageView.layer.borderColor = UIColor.white.cgColor
        self.mediaTypeImageView.layer.cornerRadius = 20
        self.mediaTypeImageView.layer.masksToBounds = true
        
        checkmarkConfig()
        
        if self.mediaType == .Image {
            let imageForImageType = UIImage.fontAwesomeIcon(name: .fileImage, style: .solid, textColor: Colors().aquarium, size: CGSize(width: 40, height: 40))
            self.mediaTypeImageView.image = imageForImageType
            self.mainImageView.image = theItem.image
        }
        if self.mediaType == .Video {
            let imageForVideoType = UIImage.fontAwesomeIcon(name: .fileVideo, style: .solid, textColor: Colors().aquarium, size: CGSize(width: 40, height: 40))
            self.mediaTypeImageView.image = imageForVideoType
            
            if theItem.video == nil {
                return
            }
            
            //Can this fail?
            let asset = AVAsset(url: theItem.video!)
            guard let theImage = GlobalFunctions.thumbnailImageFromAvAsset(theAsset: asset) else {
                Logger.log("AVAsset to UIImage Failed")
                return
            }
            
            self.mainImageView.image = theImage
        }
    }
    
    fileprivate func checkmarkConfig() {
        checkmarkImage.frame = checkmarkFrame()
        self.addSubview(checkmarkImage)
    }
    
    //TODO adjust coords
    fileprivate func checkmarkFrame() -> CGRect {
        let vw = contentView.frame.size.width
        let vh = contentView.frame.size.height
        return CGRect(x: vw / 3, y: vh / 3, width: vw / 3, height: vh / 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
