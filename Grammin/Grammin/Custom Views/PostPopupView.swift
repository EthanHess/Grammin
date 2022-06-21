//
//  PostPopupView.swift
//  Grammin
//
//  Created by Ethan Hess on 11/23/19.
//  Copyright © 2019 EthanHess. All rights reserved.
//

import UIKit

class PostPopupView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    lazy var mainImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var optionsContainerBottom : UIView = {
        let oc = UIView()
        return oc
    }()
    
    lazy var dismissButton : UIButton = {
        let xButton = UIButton()
        xButton.setTitle("X", for: .normal)
        xButton.setTitleColor(.white, for: .normal)
        xButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return xButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        viewConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func viewConfigure() {
        let screenWith = UIScreen.main.bounds.width
        //let screenHeight = UIScreen.main.bounds.height
        mainImageView.frame = CGRect(x: 0, y: screenWith / 2, width: screenWith, height: screenWith)
        mainImageView.enableZoom() //Do we need anything else? (TODO enable drag left/right/up/down)
        addSubview(mainImageView)
        
        dismissButton.frame = CGRect(x: screenWith - 100, y: 100, width: 50, height: 50)
        cornerRadiusHandler(view: dismissButton, radius: 25)
        dismissButton.layer.borderColor = UIColor.white.cgColor
        dismissButton.layer.borderWidth = 1
        addSubview(dismissButton)
        
        addSubview(optionsContainerBottom)
        optionsContainerBottom.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 100, paddingRight: 20, width: screenWith - 40, height: 80)
        optionsContainerBottom.layer.borderColor = UIColor.white.cgColor
        optionsContainerBottom.layer.borderWidth = 1
        cornerRadiusHandler(view: optionsContainerBottom, radius: 40)
        
        //TODO add shadow?
        addSubviewsToOC()
    }
    
//    fileprivate func pinchGestureSetup() {
//
//    }
    
    fileprivate func cornerRadiusHandler(view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }
    
    fileprivate func addSubviewsToOC() {
        
    }
    
    func showImageDetail(image: UIImage) {
        Logger.log("-- MAIN THREAD --\(Thread.main)")
        mainImageView.image = image
    }
    
    func showVideoDetail(videoURL: String) {
        
    }
    
    @objc fileprivate func shareTapped() {
        
    }
    
    @objc fileprivate func saveTapped() {
        
    }
    
    //Delegate to main VC? Also destroy of anything we need to here
    @objc fileprivate func dismissTapped() {
        self.isHidden = true
    }
}
