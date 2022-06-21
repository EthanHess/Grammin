//
//  MainFeedOptionsToggleView.swift
//  Grammin
//
//  Created by Ethan Hess on 1/20/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

//MARK: Now that we've subclassed options two layers deep, double delegate pattern is probably bad and we should use a notifaction / Combine

protocol MainFeedOptionsHomeDelegate : class {
    func viewTappedWithTagForHome(_ tag: Int)
}

//This toggles from home screen
class MainFeedOptionsToggleView: UIView {

    
    weak var delegate : MainFeedOptionsHomeDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Properties
    
    let profileImageView: PostCellImageView = {
        let imageView = PostCellImageView()
        imageView.backgroundColor = Colors().neptuneBlue
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //TODO add options view
    
    let optionsContainerMain: MainFeedOptionsContainer = {
        let container = MainFeedOptionsContainer()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        return container
    }()

    //Pragma mark init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        
        //viewSetup()
        self.perform(#selector(viewSetup), with: nil, afterDelay: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func viewSetup() {
        
        let viewWidth = frame.size.width - 20;
        self.addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: viewWidth, height: viewWidth)
        profileImageView.layer.cornerRadius = (frame.size.width - 20) / 2
        
        self.addSubview(optionsContainerMain)
        optionsContainerMain.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: viewWidth, height: frame.size.height - (viewWidth + 10))
        optionsContainerMain.layer.cornerRadius = 5
        optionsContainerMain.layer.borderWidth = 1
        optionsContainerMain.layer.borderColor = UIColor.white.cgColor
        optionsContainerMain.delegate = self
        
        self.perform(#selector(viewSetupWrapper), with: nil, afterDelay: 0.25)
    }
    
    @objc fileprivate func viewSetupWrapper() {
        optionsContainerMain.setUpViewsPublic()
    }
}

extension MainFeedOptionsToggleView: MainFeedOptionsContainerDelegate {
    func viewTappedWithTag(_ tag: Int) {
        self.delegate?.viewTappedWithTagForHome(tag)
    }
}
