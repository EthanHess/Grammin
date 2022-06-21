//
//  ChosenAssetsScrollView.swift
//  Grammin
//
//  Created by Ethan Hess on 6/22/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import AVKit

class ChosenAssetsScrollView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: Properties
    let scrollView : UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    var items : [CollectionItem] = []
    var viewArray : [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //scrollSetup()
        self.perform(#selector(scrollSetup), with: nil, afterDelay: 0.25)
        extras()
    }
    
    @objc fileprivate func scrollSetup() {
        self.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        
        addSubview(scrollView)
        scrollView.frame = self.bounds
        scrollView.isPagingEnabled = true //snap
        scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
    }
    
    fileprivate func extras() {
        self.stylizeUIView(theView: self, cornerRadius: 5, borderWidth: 1, borderColor: .white, bgColor: .darkGray)
    }
    
    fileprivate func clearScrollView() {
        for theView in viewArray {
            theView.removeFromSuperview()
        }
    }
    
    //If one image / video, will be bigger, if more, will be smaller
    func animateToSizeForAssetCount(count: Int) {

    }
    
    //NOTE: Can check duplicates in parent VC
    func configureScrollWithItems(items: [CollectionItem]) {
        clearScrollView()
        viewArray.removeAll()
        
        var x = CGFloat(0.0)
        
        for i in 0..<items.count {
            let dimension = CGFloat(self.frame.size.height - 10)
            let frameForView = CGRect(x: x, y: CGFloat(5), width: dimension, height: dimension)
            let theView = UIView(frame: frameForView)
            
            theView.layer.cornerRadius = 5
            theView.tag = i
            theView.isUserInteractionEnabled = true
            theView.backgroundColor = .black
            viewArray.append(theView)
            
            let theItem = items[i]
            //TODO factor in other types
            configureViewWithType(type: theItem.media == "image" ? "image" : "video", theView: theView, item: theItem)
            
            //Do I need to add :? Make sure it sends index with tap
            //let tap = UITapGestureRecognizer(target: self, action: #selector(viewTappedAtIndex))
            //storyView.addGestureRecognizer(tap)
        
            scrollView.addSubview(theView)
            
            x = x + dimension
        }
    }
    
    fileprivate func miniImageViewFrame(theView: UIView) -> CGRect {
        return CGRect(x: 10, y: 10, width: theView.frame.size.width - 20, height: theView.frame.size.height - 20)
    }
    
    //MARK: Can move to GF
    fileprivate func stylizeUIView(theView: UIView, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, bgColor: UIColor) {
        theView.layer.cornerRadius = cornerRadius
        theView.layer.borderWidth = borderWidth
        theView.layer.borderColor = borderColor.cgColor
        theView.backgroundColor = bgColor
        theView.layer.masksToBounds = true
    }
    
    fileprivate func configureViewWithType(type: String, theView: UIView, item: CollectionItem) {
        
        let iv = UIImageView()
        iv.frame = miniImageViewFrame(theView: theView)
        self.stylizeUIView(theView: iv, cornerRadius: 5, borderWidth: 1, borderColor: .white, bgColor: .darkGray)
        theView.addSubview(iv)
        
        if type == "image" {
            iv.image = item.image
            //Aspect fit?
        } else if type == "video" {
            if item.video == nil {
                return
            }
            let asset = AVAsset(url: item.video!)
            guard let theImage = GlobalFunctions.thumbnailImageFromAvAsset(theAsset: asset) else {
                Logger.log("AVAsset to UIImage Failed")
                return
            }
            iv.image = theImage
        }
    }
    
    deinit {
        //TODO add/remove tap observation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ChosenAssetsScrollView : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
