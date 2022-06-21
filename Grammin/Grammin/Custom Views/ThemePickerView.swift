//
//  ThemePickerView.swift
//  Grammin
//
//  Created by Ethan Hess on 3/29/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//TODO have global enum
//TODO add delegate for selection and highlight chosen
class ThemePickerView: UIView {
    
    //For now three UI themes (Space, White and Aqua)
    let spaceView: ThemePickerSubview = {
        let tpsv = ThemePickerSubview()
        return tpsv
    }()
    
    let whiteView: ThemePickerSubview = {
        let tpsv = ThemePickerSubview()
        return tpsv
    }()
    
    let oceanView: ThemePickerSubview = {
        let tpsv = ThemePickerSubview()
        return tpsv
    }()
    
    //TODO add labels and gesture rec.
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
        backgroundColor = .black //Change for scheme?
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
    }
    
    //Assume height is 220, could use stack view, but we want more versatility for now
    fileprivate func viewSetup() {
        addSubview(spaceView)
        spaceView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 60)
        cornerRadiusForView(view: spaceView, radius: 5)
        spaceView.configureWithTheme(theme: 0)
        
        addSubview(whiteView)
        whiteView.anchor(top: spaceView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 60)
        cornerRadiusForView(view: whiteView, radius: 5)
        whiteView.configureWithTheme(theme: 1)
        
        addSubview(oceanView)
        oceanView.anchor(top: whiteView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 60)
        cornerRadiusForView(view: oceanView, radius: 5)
        oceanView.configureWithTheme(theme: 2)
    }
    
    fileprivate func cornerRadiusForView(view: UIView, radius: CGFloat) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
