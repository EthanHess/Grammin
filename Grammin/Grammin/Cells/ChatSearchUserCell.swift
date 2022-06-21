//
//  ChatSearchUserCell.swift
//  Grammin
//
//  Created by Ethan Hess on 1/20/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class ChatSearchUserCell: UITableViewCell {

    let userProfileImageView : PostCellImageView = {
        let iv = PostCellImageView()
        iv.image = UIImage(named: "userFemaleBrunette")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    //Add/remove from chat
    let checkMarkImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    var user : User? {
        didSet {
            
            viewSetup()
            self.backgroundColor = .mainBlue()
            
            guard let username = user?.username else {
                Logger.log("NO UN")
                return
            }
            usernameLabel.text = username
            guard let imageURL = user?.profileImageUrl else {
                Logger.log("NO URL")
                return
            }
            userProfileImageView.loadImage(urlString: imageURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate func viewSetup() {
        contentView.addSubview(userProfileImageView)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 40)
        
        contentView.addSubview(checkMarkImageView)
        checkMarkImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
    }
}
