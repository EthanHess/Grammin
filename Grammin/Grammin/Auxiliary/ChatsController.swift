//
//  ChatsController.swift
//  Grammin
//
//  Created by Ethan Hess on 1/3/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//Firebase can listen for children added but may also want to use some sort of socket for this
class ChatsController: NSObject {
    
    //For when they create new
    static func seeIfChatAlreadyExistsWithParticipants(users: [User], currentUserID: String, completion: @escaping ((_ doesExist: Bool, _ chat: Chat?) -> Void)) {
 
        //Not necessarily ideal Big O but NoSQL makes group chats a bit hard, will be good for MVP though as long as huge amounts of users aren't in one single chat

        //Loop through all users chats and check if one contains all users in users array, not more or less however, the exact same UID array
        fDatabase.child(mainChatsNode).child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                
//                //Semaphore (If no longer needed, remove)
//                let semaphore = DispatchSemaphore(value: 0)
//                let s_queue = DispatchQueue(label: "semaphore_queue")
//                s_queue.async {
//
//                }
                
                //Set to compare UIDs to see if chat exists already (Set = order doesn't matter, Array = order matters)
                var userSet = Set(users.map({ $0.uid }))
                userSet.insert(currentUserID) //add cur uid
                let chatSnaps = snapshot.children.allObjects as! [DataSnapshot]
                var exists = false //defaults to no
                var existingChat : Chat?
                
                for theSnap in chatSnaps {
                    let snapDict = theSnap.value as! [String : Any]
                    let chatUsers = snapDict[chatParticipantsKey] as! [String]
                    let chatUsersSet = Set(chatUsers.map({ $0 }))
                    
                    //Does order matter here?
                    if userSet == chatUsersSet {
                        exists = true
                        var theChat = Chat(chatDict: snapDict)
                        theChat.chatID = theSnap.key
                        existingChat = theChat
                        //break
                    }
                }

                completion(exists, existingChat)
            } else {
                //User does not have chats yet, answer is no
                completion(false, nil)
            }
        }
    }
    
    
    
    
    //TODO: Handle creating a chat with yourself
    static func createNewChatWithSelf(creatorUID: String, chatDict: Dictionary<String, Any>, completion: @escaping ((_ success: Bool, _ chatRef: DatabaseReference?) -> Void)) {
        //TODO imp.
    }
    
    //TODO: Timestamp
    
    //MARK: NOTE: DispatchGroup may be more appropriate than Semaphore for group network calls
    static func createNewChatWithCreator(creatorUID: String, chatDict: Dictionary<String, Any>, users: [User], completion: @escaping ((_ success: Bool, _ chatRef: DatabaseReference?) -> Void)) {
        
        Logger.log("Creator UID \(creatorUID)")
        
        fDatabase.child(mainChatsNode).child(creatorUID).childByAutoId().setValue(chatDict) { (error, ref) in
            if error != nil {
                Logger.log("\(error!.localizedDescription)")
                completion(false, nil)
            } else {
                let semaphore = DispatchSemaphore(value: 0)
                let s_queue = DispatchQueue(label: "semaphore_queue")
                s_queue.async {
                    for newChatMember in users {
                        //Is "ref.key" the right thing to put here?
                        fDatabase.child(mainChatsNode).child(newChatMember.uid).child(ref.key).setValue(chatDict) { (error, ref) in
                            if error != nil {
                                Logger.log("Error adding user to chat \(error!.localizedDescription)")
                                semaphore.signal()
                            } else {
                                Logger.log("Successfully added \(newChatMember.username)")
                                semaphore.signal()
                            }
                        }
                        semaphore.wait()
                    }
                    DispatchQueue.main.async {
                        completion(true, ref)
                    }
                }
            }
        }
    }
    
    
    //Removes all users, messages and chat object itself
    //NOTE: only chat creator can do this, check!
    //TODO: Need to delete all associated data like images / videos etc.
    static func deleteChatWithChatID(chatID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        //TODO loop through associated users and delete
    }
    
    //MARK: Adding + removing user (only creator can)
    static func addRemoveUserHandler(chatID: String, userID: String, add: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //MARK: Chat fetching
    
    //Should we just store Chat Keys to User's node so we don't have to save the whole object? Although saving whole object shouldn't be too expensive and we don't have to make any requests in main chats list
    static func fetchChatsForUser(userID: String, completion: @escaping ((_ chats: [Chat]?) -> Void)) {
        var completionArray : [Chat] = []
        fDatabase.child(mainChatsNode).child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                    var chat = Chat(chatDict: babySnap.value as! Dictionary)
                    chat.chatID = babySnap.key
                    completionArray.append(chat)
                }
                completion(completionArray)
            } else {
                completion(completionArray)
            }
        }
    }
    
    //Messages, paginate ideally, maybe do in VC (pagination is easier)
    static func fetchAllMessagesForChat(chatID: String, completion: @escaping ((_ messages: [Message]?) -> Void)) {
         var completionArray : [Message] = []
        fDatabase.child(messagesNode).child(chatID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                    var message = Message(messageDict: babySnap.value as! Dictionary)
                    message.messageID = babySnap.key
                    completionArray.append(message)
                }
                completion(completionArray)
            } else {
                completion(completionArray)
            }
        }
    }
    
    //TODO notify user (Firebase Functions)
    static func addMessageToChat(chatID: String, messageDict: Dictionary<String, Any>, completion: @escaping ((_ success: Bool) -> Void)) {
        fDatabase.child(messagesNode).child(chatID).childByAutoId().setValue(messageDict) { (error, ref) in
            if error != nil {
                Logger.log("\(error!.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    //TODO add messages observer in VC
}
