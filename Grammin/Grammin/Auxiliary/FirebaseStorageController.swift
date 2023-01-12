//
//  FirebaseStorageController.swift
//  Grammin
//
//  Created by Ethan Hess on 8/22/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class FirebaseStorageController: NSObject {
    
    //NOTE: Completion can finish with a Result<Success, Failure> enum, may be cleaner
    
    //When people delete posts, change pics, delete messages / stories etc.
    static func removeDownloadURL(URL: String, completion: @escaping ((_ success: Bool) -> Void)) {
        let sRef = fStorage.storage.reference(forURL: URL)
        sRef.delete { (error) in
            if error != nil {
                Logger.log("\(error!.localizedDescription)")
                completion(false)
            } else {
                Logger.log("Success deleting URL \(URL)")
                completion(true)
            }
        }
    }
    
    //TODO move upload code here for profile + posts, and eventually everything else
    static func returnURLFromURLString(urlString: String, completion: @escaping(_ url: URL?) -> Void) {
        let ref = fStorage.storage.reference(forURL: urlString)
        ref.downloadURL { (url, error) in
            if error != nil {
                Logger.log((error?.localizedDescription)!)
                completion(nil)
            } else {
                completion(url!)
            }
        }
    }
}
