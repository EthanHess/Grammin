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
    
    @objc fileprivate func sharePhoto() {
        
        //TODO add loading Icon
        guard let caption = textView.text, caption.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
    
        FirebaseController.uploadImageDataToFirebase(data: uploadData, path: PostsReference) { (theURL) in
            
            //alert with type enum in case of nil values
            guard let url = theURL else { Logger.log("no URL"); return }
            guard let postImage = self.selectedImage else { Logger.log("no post image"); return }
            guard let caption = self.textView.text else { Logger.log("no caption"); return }

            let newPost = [imageUrlKey: url, postCaptionKey: caption, imageWidthKey: postImage.size.width, imageHeightKey: postImage.size.height, createdAt: Date().timeIntervalSince1970] as [String : Any]
            
            self.writeToFirebaseWithDictionary(newPost: newPost)
        }
    }
    
    
    fileprivate func writeToFirebaseWithDictionary(newPost: [String: Any]) {
        if authed() {
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
