//
//  MessageTableViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/15/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewCell: UITableViewCell {
    
    let senderImageView : PostCellImageView = {
        let iv = PostCellImageView()
        return iv
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        return label
    }()
    
    let bodyField : UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.textColor = .white //TODO update this?
        return tv
    }()
    
    let containerView : UIView = {
        let cv = UIView()
        return cv
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithMessage(message: Message) {
        //Shoud set this in main (parent) view and pass as parameter?
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        //Left, blue for current user, right, dark gray for other user
        let setupForLeft = currentUID == message.messageAuthorUID
        
        self.backgroundColor = .clear //BG is clear then container view moves accordingly
        self.contentView.backgroundColor = .clear
        let containerBGColor = setupForLeft == true ? Colors().neptuneBlue : Colors().customGray
        
        containerView.frame = containerFrame(currentUser: setupForLeft)
        containerView.backgroundColor = containerBGColor
        self.addSubview(containerView)
        
        senderImageView.frame = profileFrame(currentUser: setupForLeft)
        containerView.addSubview(senderImageView)
        
        //NOTE: Will want to store array of index path heights to size this and expand cell accordingly
        //Will also have option to add media / video / image etc.
        containerView.addSubview(bodyField)
        bodyField.anchor(top: self.topAnchor, left: senderImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        bodyField.text = message.bodyText
        
        //NOTE: This could cause flickering, perhaps add download task to cell, and cancel on dequeue
        FirebaseController.fetchUserWithUID(userID: message.messageAuthorUID) { (user) in
            if let theUser = user {
                self.senderImageView.loadImage(urlString: theUser.profileImageUrl)
            }
        }
        
        frameStylize(view: containerView, profile: false)
        frameStylize(view: senderImageView, profile: true)
        frameStylize(view: bodyField, profile: false)
    }
    
    fileprivate func frameStylize(view: UIView, profile: Bool) {
        view.layer.cornerRadius = profile == true ? view.frame.size.width / 2 : 0.5
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        //TODO shadow?
    }
    
    //Main view
    fileprivate func containerFrame(currentUser: Bool) -> CGRect {
        let viewWidth = self.frame.size.width
        let viewHeight = CGFloat(80)
        
        let xCoord = currentUser == true ? viewWidth / 5 : 0
        let yCoord = CGFloat(10)
        let width = viewWidth - ((viewWidth / 5) + 10)
        let height = viewHeight - 20
        
        return CGRect(x: xCoord, y: yCoord, width: width, height: height)
    }
    
    //IV + Label container
    fileprivate func profileFrame(currentUser: Bool) -> CGRect {
        let viewHeight = CGFloat(80)
        return CGRect(x: 10, y: 10, width: viewHeight - 20, height: viewHeight - 20)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //TODO add task and cancel
    }
}
