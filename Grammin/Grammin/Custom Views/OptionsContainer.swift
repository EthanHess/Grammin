//
//  OptionsContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 1/20/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//This is for chat, rename fo be specific?
class OptionsContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //TODO shadows
    //MARK: Why are these lazy? 
    lazy var followingButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainBlue()
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var searchUserButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.darkGray
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        self.perform(#selector(viewSetup), with: nil, afterDelay: 0.25)
    }
    
    @objc fileprivate func viewSetup() {
        let width = (self.frame.size.width / 2) - 50
        addSubview(followingButton)
        followingButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        followingButton.frame = CGRect(x: 25, y: 5, width: width, height: 40)
        addSubview(searchUserButton)
        searchUserButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        searchUserButton.frame = CGRect(x: width + 75, y: 5, width: width, height: 40)
        cornerRadiusForView(view: followingButton, radius: 20)
        cornerRadiusForView(view: searchUserButton, radius: 20)
    }
    
    fileprivate func cornerRadiusForView(view: UIView, radius: CGFloat) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    //TODO delegate
    @objc func followTapped() {
        followingButton.backgroundColor = .mainBlue()
        searchUserButton.backgroundColor = UIColor.darkGray
    }
    
    @objc func searchTapped() {
        followingButton.backgroundColor = UIColor.darkGray
        searchUserButton.backgroundColor = .mainBlue()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
