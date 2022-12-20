//
//  Story.swift
//  Grammin
//
//  Created by Ethan Hess on 6/12/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation

struct Story {
    
    //Story URL's / display info etc. will be stored in segment, this will be parent object
    
    var storyID : String? //Snapshot key
    let storyAuthorUID : String?
    let storyDownloadURL : String?
    let storyMediaType : String?
    let timestamp : Date
    let storyText : String?
    var segmentCount : Int = 0 //To set after, when segments are checked for time (when to delete)
    
    //TODO: account for highlighted etc.?
    
    init(storyDict: [String: Any]) {
        self.storyAuthorUID = storyDict[storyAuthorUIDKey] as? String ?? ""
        let secondsFrom1970 = storyDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    
        self.storyDownloadURL = storyDict["storyDownloadURL"] as? String ?? ""
        self.storyMediaType = storyDict["storyMediaType"] as? String ?? ""
        self.storyText = storyDict["storyText"] as? String ?? ""
    }
}
