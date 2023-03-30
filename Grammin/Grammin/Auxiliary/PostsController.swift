//
//  PostsController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/27/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//Currently doing this a different way in FirebaseController but keep for reference

class PostsController: NSObject {

    static func fetchPostsOfThoseIFollow(myUID: String, arrayOfWhoIFollow: [String], completion: @escaping ((_ postArray: [Post]?) -> Void)) {
        var completionArray : [Post] = []
        let dispatcher = DispatchGroup()
        for uid in arrayOfWhoIFollow {
            dispatcher.enter()
            fDatabase.child(PostsReference).child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                        //Do we want user object attached to post? Maybe remove?
                        let post = Post(user: User(uid: uid, dictionary: ["":""]), postDict: babySnap.value as! [String : Any])
                        //TODO set post ID here
                        completionArray.append(post)
                    }
                    dispatcher.leave()
                } else {
                    dispatcher.leave()
                    Logger.log("--- NO POST SNAPSHOT ---")
                }
            }
        }
        
        dispatcher.notify(queue: .main) {
            completion(completionArray)
        }
    }
    
    static func fetchMyPosts(myUID: String, completion: @escaping ((_ postArray: [Post]?) -> Void)) {
        var completionArray : [Post] = []
        let dispatcher = DispatchGroup()
        fDatabase.child(PostsReference).child(myUID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                    let post = Post(user: User(uid: "", dictionary: ["":""]), postDict: babySnap.value as! [String : Any])
                    completionArray.append(post)
                }
                dispatcher.leave()
            } else {
                dispatcher.leave()
                Logger.log("--- NO POSTS FOR ME ---")
                //completion(completionArray)
            }
        }
        dispatcher.notify(queue: .main) {
            completion(completionArray)
        }
    }
    
//    static func deletePost(_ uid: String, postID: String, completion: @escaping ((_ success: Bool) -> Void)) {
//        //MARK: Make sure all associated data is deleted, i.e. storage and comments / likes etc.
//        //Dispatch group will let us know when it's all done or failed
//    }
}
