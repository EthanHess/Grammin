//
//  LikeController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/27/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

class LikeController: NSObject {

    //NOTE: May also want to use .onDisconnectUpdateChildValues to clear things up, will do network error handling behind the scenes
    
    //TODO also for comment/story etc.
    static func addOrRemoveLikeToPost(likerUID: String, postID: String, completion: @escaping((_ success: Bool, _ liked: Bool) -> Void)) {
        
        let postLikesRef = fDatabase.child(PostLikesReference).child(postID).child(likerUID)
        let postUsersRef = fDatabase.child(UserLikesReference).child(likerUID).child(postID)
        
        let dg = DispatchGroup()
        
        var success = true
        var liked = true
        
        //If exists, remove, if not add
        
        dg.enter()
        postLikesRef.observeSingleEvent(of: .value) { plShapshot in
            if plShapshot.exists() {
                postLikesRef.removeValue { error, ref in
                    if error != nil { success = false }
                    liked = false
                    dg.leave()
                }
            } else {
                postLikesRef.setValue("") { error, ref in
                    if error != nil { success = false }
                    liked = true
                    dg.leave()
                }
            }
        }
        
        dg.enter()
        postUsersRef.observeSingleEvent(of: .value) { ulSnapshot in
            if ulSnapshot.exists() {
                postUsersRef.removeValue { error, ref in
                    if error != nil { success = false }
                    dg.leave()
                }
            } else {
                postUsersRef.setValue("") { error, ref in
                    if error != nil { success = false }
                    dg.leave()
                }
            }
        }
        
        dg.notify(queue: .main) {
            completion(success, liked)
        }
    }
    
    //For when likes detail VC appears, will want to paginate / query in case there are thousands / millions
    static func fetchLikesForPost(postID: String, completion: @escaping ((_ likes: [Like]) -> Void)) {
        var completionArray : [Like] = []
        fDatabase.child(PostLikesReference).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let snapChildren = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapChildren {
                        let likeDict = Like(likeDict: snap.value as! [String : Any])
                        completionArray.append(likeDict)
                    }
                    completion(completionArray)
                }
            } else {
                completion([])
            }
        }
    }
    
    //TODO Fetch all stuff user has liked
    
    //To display under pots, quick nonexpensive fetch
    static func fetchLikeCountForPost(postID: String, completion: @escaping ((_ likeCount: Int) -> Void)) {
        fDatabase.child(PostLikeCountReference).child(postID).observeSingleEvent(of: .value) { snapshot in
            guard let completionInt = snapshot.value as? Int else {
                completion(0)
                return
            }
            completion(completionInt)
        }
    }
    
    //Store count (efficient)
    static func updatePostLikeCount(count: Int) {
        
    }
    
    static func postLiked(likerUID: String, postID: String, completion: @escaping ((_ liked: Bool) -> Void)) {
        let postLikesRef = fDatabase.child(PostLikesReference).child(postID).child(likerUID)
        postLikesRef.observeSingleEvent(of: .value) { plShapshot in
            completion(plShapshot.exists())
        }
    }
}
