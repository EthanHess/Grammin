//
//  CustomNavigationBar.swift
//  Grammin
//
//  Created by Ethan Hess on 1/5/23.
//  Copyright © 2023 EthanHess. All rights reserved.
//

import UIKit

//TODO imp. w/ font awesome etc.
class CustomNavigationBar: UIView {

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
