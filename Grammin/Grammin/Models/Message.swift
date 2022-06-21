//
//  Message.swift
//  Grammin
//
//  Created by Ethan Hess on 1/3/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import Foundation

struct Message {
    
    var chatID : String? //Parent snap key
    var messageID : String? //This snap key
    
    let messageAuthorUID : String //Can access FCM Token, URL etc.
    let imageURL : String
    let videoURL : String
    let mediaType : String
    let bodyText : String
    let multiple : Bool //Should have scroll option for images in message cell?
    let timestamp : Date
    
    init(messageDict: [String: Any]) {
        self.messageAuthorUID = messageDict[messageAuthorUIDKey] as? String ?? ""
        self.imageURL = messageDict[imageUrlKey] as? String ?? ""
        self.videoURL = messageDict[videoURLKey] as? String ?? ""
        self.mediaType = messageDict[mediaTypeKey] as? String ?? ""
        self.bodyText = messageDict[messageBodyTextKey] as? String ?? ""
        self.multiple = messageDict[multipleKey] as? Bool ?? false
        let secondsFrom1970 = messageDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
