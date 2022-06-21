//
//  FollowingController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/27/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class FollowingController: NSObject {
    
    //MARK: Add follow / following count to user obj or have node, don't want to loop through all of the users, will hurt performance.

    static func followUnfollowUser(followerUID: String, followeeUID: String, completion: @escaping ((_ updateIsFollowing: Bool) -> Void)) {
        fDatabase.child(FollowingReference).child(followerUID).child(followeeUID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() { // is following, unfollow
                fDatabase.child(FollowingReference).child(followerUID).child(followeeUID).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        Logger.log(error?.localizedDescription ?? "")
                        completion(false) //haven't removed it yet if there's an error
                    } else {
                        completion(true)
                    }
                })
            } else { // follow, because we're not yet
                fDatabase.child(FollowingReference).child(followerUID).child(followeeUID).setValue("", withCompletionBlock: { (error, ref) in
                    if error != nil {
                        Logger.log(error?.localizedDescription ?? "")
                        completion(false) //haven't added it yet if there's an error
                    } else {
                        completion(true)
                    }
                })
            }
        }
    }
    
    //TODO imp.
    static func fetchFollowing(followerUID: String, completion: @escaping ((_ followingIDArray: [String]?) -> Void)) {
        
    }
    
    static func fetchFollowers(followingUID: String, completion: @escaping ((_ followersIDArray: [String]?) -> Void)) {
        
    }
    
    //Have unblock in same function, add param?
    static func blockUser(blockedUID: String, blockingUser: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
}
