//
//  ChatCollectionViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 1/3/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    
    let bgImageView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        return iv
    }()
    
    //TODO use subclassed image view
    let userImageViewOne : PostCellImageView = {
        let iv = PostCellImageView()
        iv.image = UIImage(named: "userFemaleBrunette")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let userImageViewTwo : PostCellImageView = {
        let iv = PostCellImageView()
        iv.image = UIImage(named: "userFemaleBrunette")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let userImageViewThree : PostCellImageView = {
        let iv = PostCellImageView()
        iv.image = UIImage(named: "userFemaleBrunette")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let lastMessageLabel : UILabel = {
        let lml = UILabel()
        lml.textColor = .white
        lml.textAlignment = .center
        return lml
    }()
    
    let dateLabel : UILabel = {
        let dl = UILabel()
        return dl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.addBackgroundImage()
        self.subviewConfig()
    }
    
    fileprivate func addBackgroundImage() {
        
//        let imageName = "chatBlueBG"
//        bgImageView.frame = self.contentView.bounds
//        contentView.addSubview(bgImageView)
//        bgImageView.image = UIImage(named: imageName)
        
        contentView.backgroundColor = UIColor.mainBlue()
    }
    
    //TODO add 3 image views for # of participants + last message label and time stamp
    //Add options icon as well?
    fileprivate func subviewConfig() {
        userImageViewOne.frame = self.ivFrameOneThreeConfig()
        userImageViewTwo.frame = self.ivFrameTwoThreeConfig()
        userImageViewThree.frame = self.ivFrameThreeThreeConfig()
        
        contentView.addSubview(userImageViewOne)
        contentView.addSubview(userImageViewTwo)
        contentView.addSubview(userImageViewThree)
        
        radiusForView(radius: 40, view: userImageViewOne, mask: true)
        radiusForView(radius: 40, view: userImageViewTwo, mask: true)
        radiusForView(radius: 40, view: userImageViewThree, mask: true)
        
        contentView.addSubview(lastMessageLabel)
        lastMessageLabel.anchor(top: contentView.topAnchor, left: userImageViewThree.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
    
    }
    
    fileprivate func radiusForView(radius: CGFloat, view: UIView, mask: Bool) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = mask
    }
    
    //TODO have collection view cell be bigger with options to schedule events etc.
    
    func configureWithChat(chat: Chat) {
        
        //lastMessageLabel.text = chat.lastMesage
        fDatabase.child("LastChatMessage").child(chat.chatID!).observeSingleEvent(of: .value) { (snap) in
            if snap.exists() {
                self.lastMessageLabel.text = snap.value as? String
            }
        }
        
        //Cache?
        for i in 0...chat.participantsArray.count - 1 {
            let userID = chat.participantsArray[i]
            if i < 3 { //Only load first 3
            FirebaseController.fetchUserWithUID(userID: userID) { (user) in
                guard let theUser = user else {
                    Logger.log("No User")
                    return
                }
                self.userImageAndUsernameAtIndex(user: theUser, index: i)
            }
            }
        }
    }
    
    //For longer if statements should use Switch, goes to condition instantly
    fileprivate func userImageAndUsernameAtIndex(user: User, index: Int) {
        if index == 0 {
            //Set label here
            if user.profileImageUrl == "" {
                return
            }
            userImageViewOne.loadImage(urlString: user.profileImageUrl)
        }
        if index == 1 {
            if user.profileImageUrl == "" {
                return
            }
            userImageViewTwo.loadImage(urlString: user.profileImageUrl)
        }
        if index == 2 {
            if user.profileImageUrl == "" {
                return
            }
            userImageViewThree.loadImage(urlString: user.profileImageUrl)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Frames
    fileprivate func ivFrameOneOneConfig() -> CGRect {
        return CGRect(x: 10, y: 10, width: 80, height: 80)
    }
    
    //Two
    fileprivate func ivFrameOneTwoConfig() -> CGRect {
        return CGRect(x: 10, y: 10, width: 80, height: 80)
    }
    
    fileprivate func ivFrameTwoTwoConfig() -> CGRect {
        return CGRect(x: 50, y: 10, width: 80, height: 80)
    }
    
    //Three
    fileprivate func ivFrameOneThreeConfig() -> CGRect {
        return CGRect(x: 10, y: 10, width: 80, height: 80)
    }
    
    fileprivate func ivFrameTwoThreeConfig() -> CGRect {
        return CGRect(x: 50, y: 10, width: 80, height: 80)
    }
    
    fileprivate func ivFrameThreeThreeConfig() -> CGRect {
        return CGRect(x: 90, y: 10, width: 80, height: 80)
    }
}
