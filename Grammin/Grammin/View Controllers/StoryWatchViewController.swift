//
//  StoryWatchViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 12/20/22.
//  Copyright © 2022 EthanHess. All rights reserved.
//

import UIKit
import AVKit
import Firebase

class StoryWatchViewController: UIViewController {
    
    var curUID : String = "" {
        didSet {
            avPlayerConfigure() //For video, TODO also images etc.
        }
    }
    
    //Could also just have Story object if we'll use more
    var curStoryID = ""
    var curStoryDownloadURL = ""
    
    var customNavBar : CustomNavigationBar = {
        let cnb = CustomNavigationBar()
        return cnb
    }()
    
    var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resize
        return layer
    }()
    
    let containerImage: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let authorImageView: PostCellImageView = {
        let aiv = PostCellImageView()
        return aiv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navConfigure()
    }
    
    fileprivate func navConfigure() {
        let navWH = CGFloat(self.view.frame.size.width)
        let navH = CGFloat(100)
        
        //Font Awesome gesture handlers
        customNavBar.frame = CGRect(x: 0, y: 50, width: navWH, height: navH)
        customNavBar.backgroundColor = Colors().customGray //TODO set internally, better practice
        customNavBar.subviewsForNavBar()
        customNavBar.delegate = self
        view.addSubview(customNavBar)
    }
    
    fileprivate func avPlayerConfigure() {
        containerImage.frame = self.view.bounds
        view.addSubview(containerImage)
        authorImageView.frame = CGRect(x: 20, y: 100, width: 50, height: 50)
        authorImageView.loadImage(urlString: curUID) //Needs to be profile URL
        containerImage.addSubview(authorImageView)
        
        fDatabase.child(StoriesReference).child(curUID).observe(.value) { snapshot in
            if snapshot.exists() {
                let snapshotArray = snapshot.children.allObjects as? [DataSnapshot]
                let storyDict = snapshotArray?.first
                if let dict = storyDict?.value {
                    let story = Story(storyDict: dict as! [String : Any])
                    self.curStoryID = storyDict!.key //can key not exist
                    self.curStoryDownloadURL = story.storyDownloadURL != nil ? story.storyDownloadURL! : ""
                    let url = URL(string: self.curStoryDownloadURL)
                    print("URL for story \(url!)")
                    self.videoSetup(url: url!)
                }
            }
        }
    }
    
    fileprivate func videoSetup(url: URL) {
//        let playerItem = AVPlayerItem(url: url)
//        self.player = AVPlayer(playerItem: playerItem)
        
        self.player = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.frame = self.containerImage.bounds
        self.containerImage.layer.addSublayer(self.playerLayer)
    }
    
    //TODO eventually animate text etc. + arrange collages
    fileprivate func configureStory() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StoryWatchViewController: CustomNavigationBarDelegate {
    func handleLeftTapped() {
        handleDismiss()
    }
    
    //The presenting view controller is responsible for dismissing the view controller it presented. If you call this method on the presented view controller itself, UIKit asks the presenting view controller to handle the dismissal.
    
    fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleRightTapped() {
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.log("No Auth")
            return
        }
        if curStoryID == "" {
            Logger.log("Story not set")
            return
        }
        GlobalFunctions.yesOrNoAlertWithTitle(title: "Delete this story?", text: "", fromVC: self) { choseYes in
            if choseYes {
                StoryController.deleteStoryWithStoryID(currentUID: uid, storyID: self.curStoryID, storyStorageURLString: self.curStoryDownloadURL == "" ? nil : self.curStoryDownloadURL) { success in
                    if success == true {
                        self.handleDismiss()
                    }
                }
            }
        }
    }
}
