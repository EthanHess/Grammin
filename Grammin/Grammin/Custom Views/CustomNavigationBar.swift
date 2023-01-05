//
//  CustomNavigationBar.swift
//  Grammin
//
//  Created by Ethan Hess on 1/5/23.
//  Copyright © 2023 EthanHess. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol CustomNavigationBarDelegate : class {
    func handleLeftTapped()
    func handleRightTapped()
}

//TODO imp. w/ font awesome etc.
class CustomNavigationBar: UIView {
    
    weak var delegate : CustomNavigationBarDelegate?

    //MARK: Properties
    var fontAwesomeContainerLeft : UIImageView = {
        let fac = UIImageView()
        return fac
    }()
    
    var fontAwesomeContainerRight : UIImageView = {
        let fac = UIImageView()
        return fac
    }()
       
    var customNavBarLeftTapGestureView : UIView = {
        let cnb = UIView()
        cnb.isUserInteractionEnabled = true
        cnb.backgroundColor = .clear
        return cnb
    }()
    
    var customNavBarRightTapGestureView : UIView = {
        let cnb = UIView()
        cnb.isUserInteractionEnabled = true
        cnb.backgroundColor = .clear
        return cnb
    }()
    
    //MARK: Life
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    func subviewsForNavBar() {
        //Left --- Right
        let navWH = self.frame.size.width / 2
        let navH = self.frame.size.height
        
        //Font Awesome gesture handlers
        customNavBarLeftTapGestureView.frame = CGRect(x: 0, y: 0, width: navWH, height: navH)
        self.addSubview(customNavBarLeftTapGestureView)
        
        let navGestureLeft = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        customNavBarLeftTapGestureView.addGestureRecognizer(navGestureLeft)
        
        customNavBarRightTapGestureView.frame = CGRect(x: navWH, y: 0, width: navWH, height: navH)
        self.addSubview(customNavBarRightTapGestureView)
        
        let navGestureRight = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))
        customNavBarRightTapGestureView.addGestureRecognizer(navGestureRight)
        
        //Font Awesome for custom nav bar
        fontAwesomeContainerLeft.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        customNavBarLeftTapGestureView.addSubview(fontAwesomeContainerLeft)
        
        //MARK: Default, but can change
        fontAwesomeContainerLeft.image = UIImage.fontAwesomeIcon(name: .github, style: .brands, textColor: .white, size: CGSize(width: 40, height: 40))
        
        fontAwesomeContainerRight.frame = CGRect(x: navWH - 60, y: 0, width: 50, height: 50)
        customNavBarRightTapGestureView.addSubview(fontAwesomeContainerRight)
        
        fontAwesomeContainerRight.image = UIImage.fontAwesomeIcon(name: .mask, style: .brands, textColor: .white, size: CGSize(width: 40, height: 40))
    }
    
    @objc fileprivate func handleLeftTap() {
        delegate?.handleLeftTapped()
    }
    
    @objc fileprivate func handleRightTap() {
        delegate?.handleRightTapped()
    }
    
    //MARK: For if we want "public" or "open", although since this will be an instance can just call it on that
    
    //Source: Swift Bible
    
//    Open access and public access enable entities to be used within any source file from their defining module, and also in a source file from another module that imports the defining module. You typically use open or public access when specifying the public interface to a framework. The difference between open and public access is described below.
    
    func setFontAwesomeImagesForLeft(_ left: UIImage, right: UIImage) {
        let isMainThread = Thread.isMainThread
        if !isMainThread {
            //No need for "weak" since nothing retains DQ
            //Can also make this an actor
            DispatchQueue.main.async {
                self.fontAwesomeContainerLeft.image = left
                self.fontAwesomeContainerRight.image = right
            }
        } else {
            fontAwesomeContainerLeft.image = left
            fontAwesomeContainerRight.image = right
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
