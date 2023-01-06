//
//  LikeController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/27/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

class LikeController: NSObject {

    //TODO also for comment/story etc.
    static func addOrRemoveLikeToPost(likerUID: String, postID: String) {
        
    }
    
    static func fetchLikesForPost(postID: String, completion: @escaping ((_ likes: [Like]) -> Void)) {
        
    }
    
    //Store count (efficient)
    static func updatePostLikeCount(count: Int) {
        
    }
}
