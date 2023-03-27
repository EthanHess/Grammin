//
//  SharePhotoViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 11/4/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import FirebaseAuth

class SharePhotoViewController: UIViewController {
    
    static let updateFeedNotification = NSNotification.Name(rawValue: updateFeedAfterPostingNotification)
    
    //Properties
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    var itemsToPost: [CollectionItem] = [] {
        didSet {
            print("Chosen items \(itemsToPost)")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uiConfig()
    }
    
    fileprivate func uiConfig() {
        view.backgroundColor = UIColor.fromRGB(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(sharePhoto))
        setUpViews()
    }
    
    //TODO update for multiple images/videos
    
    fileprivate func setUpViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(textView)
        
        //'topLayoutGuide' was deprecated in iOS 11.0: Use view.safeAreaLayoutGuide.topAnchor instead of topLayoutGuide.bottomAnchor
        
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func displayChosenMedia() {
        //TODO imp. show chosen thumbnails
    }
    
    //Leaving "selectedImage" code from original project, now adds multiple + video functionality
    @objc fileprivate func sharePhoto() {
        if authed() == false {
            GlobalFunctions.presentAlert(title: "An error occured", text: "Please check your internet connection", fromVC: self)
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if itemsToPost.isEmpty && selectedImage == nil {
            return
        }
        
        if itemsToPost.count == 1 && itemsToPost[0].media == "video" {
            handleVideo()
            return
        }
        
        if itemsToPost.count > 1 {
            handleMultiple(uid)
            return
        }
        
        //TODO add loading Icon
        guard let caption = textView.text, caption.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
    
        FirebaseController.uploadImageDataToFirebase(uid: uid, data: uploadData, path: PostsReference, uploadType: .post) { (theURL) in
            
            //alert with type enum in case of nil values
            guard let url = theURL else { Logger.log("no URL"); return }
            guard let postImage = self.selectedImage else { Logger.log("no post image"); return }
            guard let caption = self.textView.text else { Logger.log("no caption"); return }

            let newPost = [imageUrlKey: url, postCaptionKey: caption, imageWidthKey: postImage.size.width, imageHeightKey: postImage.size.height, createdAt: Date().timeIntervalSince1970] as [String : Any]
            
            self.writeToFirebaseWithDictionary(newPost: newPost)
        }
    }
    
    //Eventually add enum to account for multiple difference cases but for now just image + video
    
    //With more options use switch statement for less computing
    fileprivate func handleMultiple(_ uid: String) {
        guard let caption = textView.text, caption.count > 0 else {
            GlobalFunctions.presentAlert(title: "You need a caption for this post", text: "", fromVC: self)
            return
        }
        
        //Use Dispatch Group to monitor when all async calls complete then add everything to post dictionary
        
        //Could use a Semaphore as well but semaphores are more for general purposes, especially when synchronizing threads and protecting shared resources, in async await frameworks we can also use "AsyncSequence"
        
        let dispatchGroup = DispatchGroup()
        var downloadURLSForPost : [String] = []
        
        //This is kind of ugly and unnecessary, but just testing something (also crashes)
        
//        let downloadURLClosure = { (str: String?) in
//            if str != nil {
//                downloadURLSForPost.append(str!)
//            }
//            dispatchGroup.leave()
//        }
        
        for item in itemsToPost {
            if item.media == "image" {
                dispatchGroup.enter()
                if item.image == nil { dispatchGroup.leave() }
                guard let uploadData = UIImageJPEGRepresentation(item.image!, 0.5) else {
                    //Log failure here and leave DG
                    dispatchGroup.leave()
                    return
                }
                FirebaseController.uploadImageDataToFirebase(uid: uid, data: uploadData, path: PostsReference, uploadType: .post) { downloadURLString in
                    if downloadURLString != nil { downloadURLSForPost.append(downloadURLString!) }
                    dispatchGroup.leave()
                }
            }
            if item.media == "video" {
                dispatchGroup.enter()
                if item.video == nil { dispatchGroup.leave() }
                FirebaseController.uploadVideoDataToFirebase(uid: uid, url: item.video!, path: "", uploadType: .post) { downloadURLString in
                    if downloadURLString != nil { downloadURLSForPost.append(downloadURLString!) }
                    dispatchGroup.leave()
                }
            }
        }
        
        
        
        //May want a struct with downloadURL as property to sync with media type although we can currently grab it from download URL str.
        
        dispatchGroup.notify(queue: .main) {
            if downloadURLSForPost.isEmpty {
                //Something went wrong, log error
                return
            }
            let newPostMultiple = [multipleKey: true, mediaArrayKey: downloadURLSForPost, postCaptionKey: caption, createdAt: Date().timeIntervalSince1970] as [String: Any]
            self.writeToFirebaseWithDictionary(newPost: newPostMultiple)
        }
    }
    
    fileprivate func handleVideo() {
        
    }
    
    fileprivate func logUploadErrorWithType() {
        //TODO Imp. if above upload fails, keep track of where + move to error logging file
    }
    
    fileprivate func writeToFirebaseWithDictionary(newPost: [String: Any]) {
            //Don't need guard here but extracts optional variable
            guard let uid = Auth.auth().currentUser?.uid else { return }
            fDatabase.child(PostsReference).child(uid).childByAutoId().setValue(newPost) { (error, reference) in
                if let theError = error {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    Logger.log(theError.localizedDescription)
                    return
                }
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotification, object: nil)
            }
    }
    
    fileprivate func authed() -> Bool {
        return Auth.auth().currentUser?.uid != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
