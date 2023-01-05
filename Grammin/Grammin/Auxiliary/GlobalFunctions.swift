//
//  GlobalFunctions.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase
import AVKit

class GlobalFunctions : NSObject {
    
    //MARK: Basic alert
    
    //W/O completion but should just have as optional in same alert function instead of two
    static func presentAlert(title: String, text: String, fromVC: UIViewController) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        fromVC.present(alertController, animated: true, completion: nil)
    }
    
    static func shadowGlowForObject(object: AnyObject) {
        if #available(iOS 13.0, *) {
            object.layer.shadowColor = UIColor.fromRGB(red: 200.0, green: 245.0, blue: 239.0).cgColor
            object.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            object.layer.shadowRadius = 5.0
            object.layer.shadowOpacity = 1.0
            object.layer.masksToBounds = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    //Should be called "yesNoAlert" or something, use other places
    
    //Refer to comment first line
    static func yesOrNoAlertWithTitle(title: String, text: String, fromVC: UIViewController, completion: @escaping ((_ choseYes: Bool) -> Void)) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            completion(true)
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (action) in
            completion(false)
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        fromVC.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: AV, should have separate AVAux file? If we do move this there
    static func thumbnailImageFromAvAsset(theAsset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: theAsset)
        let time = CMTimeMake(1, 1)
        let imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: imageRef)
        
         //NOTE: Only needed when objects are not automatically managed (memory wise)
        //CGImageRelease(imageRef)
        
        return thumbnail
    }
}
