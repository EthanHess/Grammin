//
//  Like.swift
//  Grammin
//
//  Created by Ethan Hess on 6/13/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

// Likes >> POST ID >> Like info
struct Like {
    
    var likedPostID : String?
    let likerUID : String
    let likeeUID : String
    //time stamp?
    
    init(likeDict: [String: Any]) {
        self.likerUID = likeDict[likerUIDKey] as? String ?? ""
        self.likeeUID = likeDict[likeeUIDKey] as? String ?? ""
    }
}
