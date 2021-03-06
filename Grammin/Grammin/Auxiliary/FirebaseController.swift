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
    
    static func uploadImageDataToFirebase(data: Data, path: String, completionString: @escaping  ((_ downloadURLString: String?) -> Void)) {
        
        let childString = NSString(format: "profile_image_%@", UUID().uuidString)
        let profilePicsRef = fStorage.child("ProfilePics").child(path).child(childString as String)
        
        let uploadTask = profilePicsRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                Logger.log("Error uploading: \(String(describing: error?.localizedDescription))")
            } else {
                Logger.log("Metadata: \(String(describing: metadata))")
            }
        }
        
        uploadTask.observe(.success) { (taskSnapshot) in
            
            //Works
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
        
        //Add/Remove other observers
    }
}
