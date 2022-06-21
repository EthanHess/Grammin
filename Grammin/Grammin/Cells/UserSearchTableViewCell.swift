//
//  UserSearchTableViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/30/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class UserSearchTableViewCell: UITableViewCell {
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ""), for: .normal)
        button.addTarget(self, action: #selector(optionsHandler), for: .touchUpInside)
        return button
    }()
    
    let theUsernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = Colors().neptuneBlue
        return label
    }()
    
    let profileImageView: PostCellImageView = {
        let imageView = PostCellImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewSetup()
    }
    
    fileprivate func viewSetup() {
        
    }
    
    @objc fileprivate func optionsHandler() {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
