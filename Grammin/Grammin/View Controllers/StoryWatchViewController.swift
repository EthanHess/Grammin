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
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
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
                    let url = URL(string: story.storyDownloadURL!)
                    self.videoSetup(url: url!)
                }
            }
        }
    }
    
    fileprivate func videoSetup(url: URL) {
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
