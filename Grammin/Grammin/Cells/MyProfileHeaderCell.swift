//
//  MyProfileHeaderCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/29/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//Could have in seperate delegates file
protocol UserProfileHeaderDelegate : class {
    func didChangeToListView()
    func didChangeToGridView()
    func didChangeToBookmark()
    func didTapImage() //Upload new Profile Image
}

class MyProfileHeaderCell: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    //Properties
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "navBarGridSelected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "navBarListUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    //TODO add
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "navBarSavedUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToBookmark), for: .touchUpInside)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.fromRGB(red: 93, green: 244, blue: 247)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.fromRGB(red: 93, green: 244, blue: 247)
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.fromRGB(red: 93, green: 244, blue: 247)
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.fromRGB(red: 93, green: 244, blue: 247)
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.fromRGB(red: 93, green: 244, blue: 247), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.fromRGB(red: 93, green: 244, blue: 247).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    //Make sure this updates with profile image URL
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            setupEditFollowButton()
        }
    }
    
    let profileImageView: PostCellImageView = {
        let iv = PostCellImageView()
        iv.layer.shadowColor = UIColor.fromRGB(red: 200.0, green: 245.0, blue: 239.0).cgColor
        iv.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        iv.layer.shadowRadius = 5.0
        iv.layer.shadowOpacity = 1.0
        iv.layer.masksToBounds = false
        iv.backgroundColor = .white
        iv.image = UIImage(named: "userFemaleBrunette")
        return iv
    }()
    
    //Setup funcs
    fileprivate func setupEditFollowButton() {
        
        //If current user, will be edit
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            //Edit mode
        } else {
            self.checkFollowing(currentId: currentLoggedInUserId, profileId: userId)
        }
    }
    
    fileprivate func checkFollowing(currentId: String, profileId: String) {
        fDatabase.database.reference().child(FollowingReference).child(currentId).child(profileId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
            } else {
                self.setupFollowStyle()
            }
        }, withCancel: { (err) in
            print("Failed to check if following:", err)
        })
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = Colors().neptuneBlue
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        self.editProfileFollowButton.layer.shadowColor = UIColor.fromRGB(red: 200.0, green: 245.0, blue: 239.0).cgColor
        self.editProfileFollowButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.editProfileFollowButton.layer.shadowRadius = 5.0
        self.editProfileFollowButton.layer.shadowOpacity = 1.0
        self.editProfileFollowButton.layer.masksToBounds = false
    }
    
    //Handler funcs
    @objc func handleEditProfileOrFollow() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        FollowingController.followUnfollowUser(followerUID: currentLoggedInUserId, followeeUID: userId) { (isFollowing) in
            if isFollowing == false {
                //TODO Update UI here
            } else {
                
            }
        }
    }
    
    //TODO have keys instead of repeating the string for image name
    fileprivate func changeImageAtIndex(index: Int) {
        if index == 0 {
            gridButton.setImage(UIImage(named: "navBarGridSelected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            bookmarkButton.setImage(UIImage(named: "navBarSavedUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            listButton.setImage(UIImage(named: "navBarListUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if index == 1 {
            bookmarkButton.setImage(UIImage(named: "navBarSavedUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            listButton.setImage(UIImage(named: "navBarListSelected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            gridButton.setImage(UIImage(named: "navBarGridUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if index == 2 {
            bookmarkButton.setImage(UIImage(named: "navBarSavedSelected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            listButton.setImage(UIImage(named: "navBarListUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
            gridButton.setImage(UIImage(named: "navBarGridUnselected")!.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    //TODO add
    
    
    //TODO update buttons
    @objc func handleChangeToGridView() {
        changeImageAtIndex(index: 0)
        print("Changing to grid view")
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    @objc func handleChangeToListView() {
        changeImageAtIndex(index: 1)
        print("Changing to list view")
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    @objc func handleChangeToBookmark() {
        changeImageAtIndex(index: 2)
        delegate?.didChangeToBookmark()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subviewConfig()
        self.backgroundColor = .black
    }
    
    fileprivate func tapForProfileImageView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func handleImageTap() {
        delegate?.didTapImage()
    }
    
    fileprivate func subviewConfig() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        //GlobalFunctions.shadowGlowForObject(object: profileImageView)
        tapForProfileImageView()
        
        bottomToolbar()
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        userStats()
        addSubview(editProfileFollowButton)
        
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    fileprivate func userStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func bottomToolbar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
}
