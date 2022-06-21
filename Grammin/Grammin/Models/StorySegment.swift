//
//  StorySegment.swift
//  Grammin
//
//  Created by Ethan Hess on 4/16/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import Foundation

struct StorySegment {
    
    var storyParentID : String? //Parent snapshot key
    var segmentID : String? //Child (this one)
    
    let segmentAuthorUID : String //Can access FCM Token, URL etc. -- SAME AS STORY ID --
    let imageURL : String
    let videoURL : String
    let mediaType : String
    let bodyText : String
    let multiple : Bool 
    let timestamp : Date
    
    init(segDict: [String: Any]) {
        self.segmentAuthorUID = segDict[segmentAuthorUIDKey] as? String ?? ""
        self.imageURL = segDict[imageUrlKey] as? String ?? ""
        self.videoURL = segDict[videoURLKey] as? String ?? ""
        self.mediaType = segDict[mediaTypeKey] as? String ?? ""
        self.bodyText = segDict[commentCaptionKey] as? String ?? ""
        self.multiple = segDict[multipleKey] as? Bool ?? false
        let secondsFrom1970 = segDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
