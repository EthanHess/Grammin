//
//  SearchUserCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/9/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

protocol SearchUserCellDelegate : class {
    func followTapped(user: User)
}

// -- May want to change to to Table View later --
class SearchUserCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: PostCellImageView = {
        let imageView = PostCellImageView()
        imageView.backgroundColor = Colors().neptuneBlue
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        //TODO config
        button.layer.cornerRadius = 5
//        button.layer.masksToBounds = true
        button.backgroundColor = Colors().awesomeBlack
        button.titleLabel?.textColor = Colors().lightWhiteBlue
        button.layer.borderColor = Colors().neptuneBlue.cgColor
        //button.addTarget(self, action: #selector(followUnfollowHandler), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: SearchUserCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviewConfig()
    }
    
    fileprivate func subviewConfig() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(followButton)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 80, height: 30)
        followButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        followButton.addTarget(self, action: #selector(followUnfollowHandler), for: .touchUpInside)
        followButtonShadow()
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    fileprivate func followButtonShadow() {
        followButton.layer.shadowColor = UIColor.fromRGB(red: 200.0, green: 245.0, blue: 239.0).cgColor
        followButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        followButton.layer.shadowRadius = 5.0
        followButton.layer.shadowOpacity = 1.0
        //followButton.layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func followUnfollowHandler() {
        if let user = self.user {
            self.delegate?.followTapped(user: user)
        }
    }
}
