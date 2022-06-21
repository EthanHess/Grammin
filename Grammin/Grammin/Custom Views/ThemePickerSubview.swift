//
//  ThemePickerSubview.swift
//  Grammin
//
//  Created by Ethan Hess on 3/29/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//TODO gradients?
class ThemePickerSubview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let leftView: UIView = {
        let v = UIView()
        return v
    }()
    
    let topView: UIView = {
        let v = UIView()
        return v
    }()
    
    let bottomView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 5
    }
    
    //Assume height is 60
    fileprivate func viewSetup() {
        addSubview(leftView)
        leftView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
        cornerRadiusForView(view: leftView, radius: 5)
        
        addSubview(topView)
        topView.anchor(top: topAnchor, left: leftView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 10)
        cornerRadiusForView(view: topView, radius: 5)
        
        addSubview(bottomView)
        bottomView.anchor(top: topView.bottomAnchor, left: leftView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        cornerRadiusForView(view: bottomView, radius: 5)
        
        addSubview(bottomView)
    }
    
    fileprivate func cornerRadiusForView(view: UIView, radius: CGFloat) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    func configureWithTheme(theme: Int) {
        leftView.backgroundColor = themeColorArray(theme: theme)[0]
        topView.backgroundColor = themeColorArray(theme: theme)[1]
        bottomView.backgroundColor = themeColorArray(theme: theme)[2]
        backgroundColor = themeColorArray(theme: theme)[3]
    }
    
    fileprivate func themeColorArray(theme: Int) -> [UIColor] {
        if theme == 0 {
            return [UIColor.spaceThemeOne(), UIColor.spaceThemeTwo(), UIColor.spaceThemeThree(), UIColor.spaceThemeFour()] //Will have one for each (3) views plus background
        }
        else if theme == 1 {
            return [UIColor.whiteThemeOne(), UIColor.whiteThemeTwo(), UIColor.whiteThemeThree(), UIColor.whiteThemeFour()]
        }
        else {
            return [UIColor.aquaThemeOne(), UIColor.aquaThemeTwo(), UIColor.aquaThemeThree(), UIColor.aquaThemeFour()]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
