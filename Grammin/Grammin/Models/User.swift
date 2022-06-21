//
//  User.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

//Class (reference) may be better in some cases

struct User : Equatable {
    
    //TODO follow / following count
    let uid: String
    let username: String
    let profileImageUrl: String
    var privateAccount: Bool = false //request following will be needed
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileURL"]  as? String ?? ""
        self.privateAccount = (dictionary["privateAccount"] != nil) ? dictionary["privateAccount"] as! Bool : false
    }
}
