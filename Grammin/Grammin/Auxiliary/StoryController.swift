//
//  StoryController.swift
//  Grammin
//
//  Created by Ethan Hess on 4/16/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

typealias StoryDict = Dictionary<String, Any>

class StoryController: NSObject {
    
    static func fetchStoriesOfFollowing(currentUserID: String, completion: @escaping ((_ stories: [Story]) -> Void)) {
        
    }
    
    static func fetchSegmentsOfStory(storyID: String, completion: @escaping ((_ segments: [StorySegment]) -> Void)) {
        
    }
    
    static func userHasStory(currentUID: String, completion: @escaping ((_ exists: Bool) -> Void)) {
        fDatabase.child(StoriesReference).child(currentUID).observe(.value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    //Add Result type with err / data
    static func uploadStoryForUser(currentUID: String, storyDict: StoryDict, completion: @escaping ((_ success: Bool) -> Void)) {
        fDatabase.child(StoriesReference).child(currentUID).childByAutoId().setValue(storyDict, andPriority: nil) { err, ref in
            print("--- Story set \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
        }
    }
    
    //Likely don't need anymore, the above way may be the simplest
    static func uploadSegmentToStory(storyID: String, segDict: StoryDict, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //Need to delete from storage and other places that it will appear
    //NoSQL databases will have a lot of duplicated data by nature
    
    static func deleteStoryWithStoryID(currentUID: String, storyID: String, storyStorageURLString: String?, completion: @escaping ((_ success: Bool) -> Void)) {
        fDatabase.child(StoriesReference).child(currentUID).child(storyID).removeValue { err, ref in
            print("--- Story removed \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
            if storyStorageURLString != nil {
                FirebaseStorageController.removeDownloadURL(URL: storyStorageURLString!) { success in
                    print("--- Story storage removed \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
                }
            }
        }
    }
    
    static func deleteSegmentWithSegmentID(storyID: String, segmentID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //Should be strings (the completion)?
    static func fetchViewersForSegment(storyID: String, segmentID: String, completion: @escaping ((_ viewers: [User]) -> Void)) {
        
    }
    
    static func addViewerToSegment(storyID: String, segmentID: String, viewerID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //TODO view count
}
