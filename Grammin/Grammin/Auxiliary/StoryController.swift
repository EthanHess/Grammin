//
//  StoryController.swift
//  Grammin
//
//  Created by Ethan Hess on 4/16/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import Firebase

typealias StoryDict = Dictionary<String, Any>

class StoryController: NSObject {
    
    static func fetchStoriesOfFollowing(_ currentUserID: String, completion: @escaping ((_ stories: [Story]) -> Void)) {
        
    }
    
    static func fetchSegmentsOfStory(_ storyID: String, completion: @escaping ((_ segments: [StorySegment]) -> Void)) {
        
    }
    
    static func userHasStory(_ currentUID: String, completion: @escaping ((_ exists: Bool) -> Void)) {
        //Should be "observeSingleEvent" here since "observe" does not remove observer automatically
        fDatabase.child(StoriesReference).child(currentUID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    //Add Result type with err / data
    static func uploadStoryForUser(_ currentUID: String, storyDict: StoryDict, completion: @escaping ((_ success: Bool) -> Void)) {
        fDatabase.child(StoriesReference).child(currentUID).childByAutoId().setValue(storyDict, andPriority: nil) { err, ref in
            print("--- Story set \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
            completion(err == nil)
        }
    }
    
    //Likely don't need anymore, the above way may be the simplest
    static func uploadSegmentToStory(_ storyID: String, segDict: StoryDict, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //Need to delete from storage and other places that it will appear
    //NoSQL databases will have a lot of duplicated data by nature
    
    static func deleteStoryWithStoryID(_ currentUID: String, storyID: String, storyStorageURLString: String?, completion: @escaping ((_ success: Bool) -> Void)) {
        fDatabase.child(StoriesReference).child(currentUID).child(storyID).removeValue { err, ref in
            print("--- Story removed \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
            if storyStorageURLString != nil {
                FirebaseStorageController.removeDownloadURL(URL: storyStorageURLString!) { success in
                    print("--- Story storage removed \(err != nil ? err!.localizedDescription : "") -- \(ref.key)")
                }
            }
        }
    }
    
    static func deleteSegmentWithSegmentID(_ storyID: String, segmentID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    //Should be strings (the completion)?
    
    //MARK: Can get rid of segment since it will be the same as story ? Or we can have multiple images / videos in one story (can work in later)
    
    static func fetchViewersForSegment(_ storyID: String, segmentID: String, completion: @escaping ((_ viewerIDs: [String]?) -> Void)) {
        
        fDatabase.child(StoryViewsReference).child(storyID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let snapChildren = snapshot.children.allObjects as! [DataSnapshot]
                var tempArray : [String] = []
                for childSnap in snapChildren {
                    tempArray.append(childSnap.key)
                }
                completion(tempArray)
            } else {
                completion(nil)
            }
        }
    }
    
    static func addViewerToSegment(_ storyID: String, segmentID: String, viewerID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        let mainRef = fDatabase.child(StoryViewsReference).child(storyID).child(viewerID)
        mainRef.setValue("") { err, ref in
            completion(err == nil)
        }
    }
    
    //Func when story disappears (unless highlighted). All associated data like views / comments / mentions will be deleted
    static func removeAssociatedDataFromStory(_ storyID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        //let dispatchGroup = DispatchGroup()
    }
    
    //TODO view count
}
