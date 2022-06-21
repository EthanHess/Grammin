//
//  Comment.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

struct Comment {
    
    var commentID : String? //Snapshot key
    var liked = false

    let commentAuthorUID : String //Can access FCM Token, URL etc.
    let imageURL : String
    let videoURL : String
    let mediaType : String
    let bodyText : String
    let multiple : Bool //Should have scroll option for images in comment
    let timestamp : Date
    
    init(commentDict: [String: Any]) {
        self.commentAuthorUID = commentDict[commentAuthorUIDKey] as? String ?? ""
        self.imageURL = commentDict[imageUrlKey] as? String ?? ""
        self.videoURL = commentDict[videoURLKey] as? String ?? ""
        self.mediaType = commentDict[mediaTypeKey] as? String ?? ""
        self.bodyText = commentDict[commentCaptionKey] as? String ?? ""
        self.multiple = commentDict[multipleKey] as? Bool ?? false
        let secondsFrom1970 = commentDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
