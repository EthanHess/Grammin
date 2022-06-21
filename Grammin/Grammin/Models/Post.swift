//
//  Post.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

struct Post {
    
    //TODO like / comment count
    var postID : String? //Snapshot key
    var liked = false

    let postAuthor : User //Can access FCM Token, URL etc.
    let imageURL : String
    let videoURL : String
    let mediaType : String
    let bodyText : String
    let multiple : Bool
    let timestamp : Date
    //let animation : Bool //Animate multiple images like GIF (TODO add option in story upload)
    
    //Just UID and not user object?
    init(user: User, postDict: [String: Any]) {
        self.postAuthor = user //TODO remove? 
        self.imageURL = postDict[imageUrlKey] as? String ?? ""
        self.videoURL = postDict[videoURLKey] as? String ?? ""
        self.mediaType = postDict[mediaTypeKey] as? String ?? ""
        self.bodyText = postDict[postCaptionKey] as? String ?? ""
        self.multiple = postDict[multipleKey] as? Bool ?? false
        let secondsFrom1970 = postDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
