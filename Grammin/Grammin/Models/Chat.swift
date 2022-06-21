//
//  Chat.swift
//  Grammin
//
//  Created by Ethan Hess on 1/3/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import Foundation

struct Chat {
    
    var chatID : String? //Snap key
    let participantsArray : [String] //Array of UIDs
    let chatName : String //like, group name?
    let lastMesage : String
    let chatStarterUID : String
    let timestamp : Date
    
    init(chatDict: [String: Any]) {
        self.chatStarterUID = chatDict[chatAuthorUIDKey] as? String ?? ""
        self.chatName = chatDict[chatNameKey] as? String ?? ""
        self.lastMesage = chatDict[chatLastMessageKey] as? String ?? ""
        self.participantsArray = chatDict[chatParticipantsKey] as? [String] ?? [""]
        let secondsFrom1970 = chatDict[createdAt] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
