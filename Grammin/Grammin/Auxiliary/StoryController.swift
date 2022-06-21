//
//  StoryController.swift
//  Grammin
//
//  Created by Ethan Hess on 4/16/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class StoryController: NSObject {
    
    static func fetchStoriesOfFollowing(currentUserID: String, completion: @escaping ((_ stories: [Story]) -> Void)) {
        
    }
    
    static func fetchSegmentsOfStory(storyID: String, completion: @escaping ((_ segments: [StorySegment]) -> Void)) {
        
    }
    
    static func uploadStoryForUser(currentUID: String, storyDict: Dictionary<String, Any>, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    static func uploadSegmentToStory(storyID: String, segDict: Dictionary<String, Any>, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    static func deleteStoryWithStoryID(storyID: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
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
