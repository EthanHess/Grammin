//
//  ChosenChatParticipantsContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 3/26/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class ChosenChatParticipantsContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Have scroll view/ and or realign when chat passes four users?
    
    //TODO font awesome
    
    //Image views
    lazy var firstParticipantIV : PostCellImageView = {
        let iv = PostCellImageView()
        iv.backgroundColor = Colors().coolBlue
        iv.isHidden = true
        return iv
    }()
    
    lazy var secondParticipantIV : PostCellImageView = {
        let iv = PostCellImageView()
        iv.backgroundColor = Colors().coolBlue
        iv.isHidden = true
        return iv
    }()
    
    lazy var thirdParticipantIV : PostCellImageView = {
        let iv = PostCellImageView()
        iv.backgroundColor = Colors().coolBlue
        iv.isHidden = true
        return iv
    }()
    
    lazy var fourthParticipantIV : PostCellImageView = {
        let iv = PostCellImageView()
        iv.backgroundColor = Colors().coolBlue
        iv.isHidden = true
        return iv
    }()
    
    //Labels
    lazy var firstNameLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont.systemFont(ofSize: 8)
        return lb
    }()
    
    lazy var secondNameLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont.systemFont(ofSize: 8)
        return lb
    }()
    
    lazy var thirdNameLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont.systemFont(ofSize: 8)
        return lb
    }()
    
    lazy var fourthNameLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        lb.adjustsFontSizeToFitWidth = true
        lb.font = UIFont.systemFont(ofSize: 8)
        return lb
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    func configureWithParticipants(participants: [User]) {
        if participants.count == 0 {
            for v in subviews {
                v.isHidden = true
            }
            return
        }
        
        firstParticipantIV.isHidden = participants.count < 1
        secondParticipantIV.isHidden = participants.count < 2
        thirdParticipantIV.isHidden = participants.count < 3
        fourthParticipantIV.isHidden = participants.count < 4
        
        firstNameLabel.isHidden = participants.count < 1
        secondNameLabel.isHidden = participants.count < 2
        thirdNameLabel.isHidden = participants.count < 3
        fourthNameLabel.isHidden = participants.count < 4
        
        for i in 0...participants.count-1 {
            let theUser = participants[i]
            if i == 0 {
                firstNameLabel.text = theUser.username
                firstParticipantIV.loadImage(urlString: theUser.profileImageUrl)
            }
            if i == 1 {
                secondNameLabel.text = theUser.username
                secondParticipantIV.loadImage(urlString: theUser.profileImageUrl)
            }
            if i == 2 {
                thirdNameLabel.text = theUser.username
                thirdParticipantIV.loadImage(urlString: theUser.profileImageUrl)
            }
            if i == 3 {
                fourthNameLabel.text = theUser.username
                fourthParticipantIV.loadImage(urlString: theUser.profileImageUrl)
            }
        }
    }
    
    fileprivate func cornerRadius(view: UIView, radius: CGFloat) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    fileprivate func viewSetup() {
        let ivY = 3
        let ivX = 3
        let lbY = 37
        let lbX = 3
        
        firstParticipantIV.frame = CGRect(x: ivX, y: ivY, width: 34, height: 34)
        secondParticipantIV.frame = CGRect(x: (ivX * 2) + 34, y: ivY, width: 34, height: 34)
        thirdParticipantIV.frame = CGRect(x: (ivX * 3) + 68, y: ivY, width: 34, height: 34)
        fourthParticipantIV.frame = CGRect(x: (ivX * 4) + 102, y: ivY, width: 34, height: 34)
        
        cornerRadius(view: firstParticipantIV, radius: 17)
        cornerRadius(view: secondParticipantIV, radius: 17)
        cornerRadius(view: thirdParticipantIV, radius: 17)
        cornerRadius(view: fourthParticipantIV, radius: 17)
        
        firstNameLabel.frame = CGRect(x: lbX, y: lbY, width: 34, height: 10)
        secondNameLabel.frame = CGRect(x: (lbX * 2) + 34, y: lbY, width: 34, height: 10)
        thirdNameLabel.frame = CGRect(x: (lbX * 3) + 68, y: lbY, width: 34, height: 10)
        fourthNameLabel.frame = CGRect(x: (lbX * 4) + 102, y: lbY, width: 34, height: 10)
        
        addSubview(firstParticipantIV)
        addSubview(secondParticipantIV)
        addSubview(thirdParticipantIV)
        addSubview(fourthParticipantIV)
        addSubview(firstNameLabel)
        addSubview(secondNameLabel)
        addSubview(thirdNameLabel)
        addSubview(fourthNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
