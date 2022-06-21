//
//  FirebaseStorageController.swift
//  Grammin
//
//  Created by Ethan Hess on 8/22/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class FirebaseStorageController: NSObject {
    //When people delete posts, change pics, delete messages / stories etc.
    static func removeDownloadURL(URL: String, completion: @escaping ((_ success: Bool) -> Void)) {
        fStorage.child(URL).delete { (error) in
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
}
