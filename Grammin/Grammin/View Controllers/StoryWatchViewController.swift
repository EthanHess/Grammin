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
    
    //May not need if no viewers?
    lazy var storyViewersContainerView: StoryViewersContainer = {
        let svc = StoryViewersContainer()
        return svc
    }()
    
    var originalStoryFrame : CGRect = .zero

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
        
        storyViewersConfigure()
    }
    
    //Add extension to quickly grab height / width cleaner
    fileprivate func storyViewersConfigure() {
        //Initially will be at bottom of screen
        let storyFrame = CGRect(x: 10, y: self.view.frame.size.height - 50, width: self.view.frame.size.width - 20, height: self.view.frame.size.height)
        
        storyViewersContainerView.frame = storyFrame
        originalStoryFrame = storyFrame
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragHandler(_:)))
        storyViewersContainerView.addGestureRecognizer(dragGesture)
        view.addSubview(storyViewersContainerView)
    }
    
    fileprivate func determineMediaType() {
        //TODO what to set up, images / audio / video / text / whatever
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
                    //let url = URL(string: self.curStoryDownloadURL)
                    FirebaseStorageController.returnURLFromURLString(urlString: self.curStoryDownloadURL) { url in
                        if url != nil {
                            print("URL for story \(url!)")
                            self.videoSetup(url: url!)
                            self.writeToViewers()
                            self.setupViewers()
                        }
                    }
                    
                }
            }
        }
    }
    
    //Current user watched the story
    fileprivate func writeToViewers() {
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.log("No Auth")
            return
        }
        if curStoryID == "" {
            Logger.log("Story not set")
            return
        }
        StoryController.addViewerToSegment(curStoryID, segmentID: "", viewerID: uid) { success in
            Logger.log("Write viewer (story) success \(success)")
        }
    }
    
    fileprivate func videoSetup(url: URL) {
//        let playerItem = AVPlayerItem(url: url)
//        self.player = AVPlayer(playerItem: playerItem)
        DispatchQueue.main.async {
            self.player = AVPlayer(url: url)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.frame = self.containerImage.bounds
            self.containerImage.layer.addSublayer(self.playerLayer)
        }
    }
    
    fileprivate func setupViewers() {
        //self.curStoryID
        StoryController.fetchViewersForSegment(curStoryID, segmentID: "") { viewerIDs in
            if viewerIDs != nil {
                self.storyViewersContainerView.loadViewers(viewerIDs!)
            } else {
                //WTD?
            }
        }
    }
    
    //TODO eventually animate text etc. + arrange collages
    fileprivate func configureStory() {
        
    }
    
    var lastTranslation : CGFloat = 0

    //MARK: Drag handler (raise table + shrink story content)
    @objc private func dragHandler(_ sender: UIPanGestureRecognizer) {
        //Use coordinates to animate
        
        //For story viewers frame
        let translation = sender.translation(in: self.view)
        let x = originalStoryFrame.origin.x
        
        //NOTE: Still need to handle pan downward
        let y = originalStoryFrame.origin.y + (translation.y - lastTranslation)
        
        lastTranslation = translation.y
        
        let w = originalStoryFrame.width
        let h = originalStoryFrame.height
        
        storyViewersContainerView.frame = CGRectMake(x, y, w, h)
        originalStoryFrame = storyViewersContainerView.frame
        
        Logger.log("T Y \(translation.y)")
        
        //For current story container (will shrink as SVC moves up)
        
        //containerImage.frame = CGRect(x: <#T##Int#>, y: <#T##Int#>, width: <#T##Int#>, height: <#T##Int#>)
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
                StoryController.deleteStoryWithStoryID(uid, storyID: self.curStoryID, storyStorageURLString: self.curStoryDownloadURL == "" ? nil : self.curStoryDownloadURL) { success in
                    if success == true {
                        self.handleDismiss()
                    }
                }
            }
        }
    }
}
