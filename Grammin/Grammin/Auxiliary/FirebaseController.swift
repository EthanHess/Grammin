//
//  FirebaseController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/25/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

let fDatabase = Database.database().reference()
let fStorage = Storage.storage().reference()

class FirebaseController: NSObject {
    
    //Database (Before we upgrade to Cloud Firestore!) :)

    // *Important* With Firebase you need to stop listening at the node's nested level
    
    static func stopListeningToChildAtPath(path: String) {
        fDatabase.child(path).removeAllObservers()
    }
    
    //MARK: TODO can cache needed info like name/pic etc. 
    static func fetchUserWithUID(userID: String, completion: @escaping ((_ user: User?) -> Void)) {
        if userID == "" {
            completion(nil)
        } else {
        fDatabase.child(UsersReference).child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                //If snapshot exists, should have a value, if not maybe guard?
                let theUser = User(uid: snapshot.key, dictionary: snapshot.value as! [String : Any])
                completion(theUser)
            } else {
                Logger.log("--- ERROR FETCHING USER ---")
                completion(nil)
            }
        }
        }
    }
    
    static func fetchWhoCurrentUserFollows(idString: String, completion: @escaping ((_ userIDSDict: Dictionary<String, Any>?) -> Void)) {
        fDatabase.child(FollowingReference).child(idString).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
                completion(userIdsDictionary)
            } else {
                Logger.log("--- ERROR FETCHING USER ---")
                completion(nil)
            }
        }
    }
    
    //MARK Storage (TODO Move to storage file "FirebaseStorageController", also organize code and move all storage functionality there)
    
    //This is for profile image, will want another path for post / story / chat images
    static func uploadImageDataToFirebase(data: Data, path: String, completionString: @escaping  ((_ downloadURLString: String?) -> Void)) {
        
        let childString = NSString(format: "profile_image_%@", UUID().uuidString)
        let profilePicsRef = fStorage.child("ProfilePics").child(path).child(childString as String)
        
        let uploadTask = profilePicsRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                Logger.log("Error uploading Profile Pic: \(String(describing: error?.localizedDescription))")
            } else {
                Logger.log("Metadata Profile Pic: \(String(describing: metadata))")
            }
        }
        
        uploadTask.observe(.success) { (taskSnapshot) in
            
            profilePicsRef.downloadURL(completion: { (downloadURL, error) in
                
                if error != nil {
                    Logger.log("--- ERROR ---\(String(describing: error?.localizedDescription))")
                    completionString(nil)
                    return
                }
                if let completionURL = downloadURL?.absoluteString {
                    Logger.log("--- DOWNLOAD URL --- \(completionURL)")
                    completionString(completionURL)
                } else {
                    completionString(nil)
                }
            })
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            Logger.log("--- FAILURE --- \(String(describing: snapshot.error))")
            completionString(nil)
        }
        
        //Add/Remove other observers if needed
    }
    
    static func uploadVideoDataToFirebase(uid: String, url: URL, path: String, completionString: @escaping ((_ downloadURLString: String?) -> Void)) {
        
        let childString = NSString(format: "story_video_%@", UUID().uuidString)
        let storyVideoRef = fStorage.child("StoryVideos").child(uid).child(childString as String)
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            let data = try Data(contentsOf: url)
            let uploadTask = storyVideoRef.putData(data, metadata: metadata) { (metadata, error) in
                if error != nil {
                    Logger.log("Error uploading SV: \(String(describing: error?.localizedDescription))")
                } else {
                    Logger.log("Metadata SV: \(String(describing: metadata))")
                }
            }
            uploadTask.observe(.success) { (taskSnapshot) in
                storyVideoRef.downloadURL(completion: { (downloadURL, error) in
                    if error != nil {
                        Logger.log("--- ERROR SV ---\(String(describing: error?.localizedDescription))")
                        completionString(nil)
                        return
                    }
                    if let completionURL = downloadURL?.absoluteString {
                        Logger.log("--- DOWNLOAD URL SV --- \(completionURL)")
                        completionString(completionURL)
                    } else {
                        completionString(nil)
                    }
                })
            }
            
            uploadTask.observe(.failure) { (snapshot) in
                Logger.log("--- FAILURE --- \(String(describing: snapshot.error))")
                completionString(nil)
            }
        } catch let error {
            print("Error converting story to data \(error.localizedDescription)")
            completionString(nil)
        }
    }
}
