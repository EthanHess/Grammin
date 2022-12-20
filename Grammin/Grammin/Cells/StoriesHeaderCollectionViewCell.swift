//
//  StoriesHeaderCollectionViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 12/30/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import FirebaseAuth
import FontAwesome_swift

protocol StoriesCellDelegate : class {
    func mainImageTapped()
    func storyViewTappedWithStory(story: Story)
}

class StoriesHeaderCollectionViewCell: UICollectionViewCell {
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        return sv
    }()
    
    lazy var myImageView: PostCellImageView = {
        let miv = PostCellImageView()
        return miv
    }()
    
    var viewArray : [StoryView] = [] //TODO animate corner radius like instagram
    
    weak var delegate: StoriesCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //TODO customize
        contentView.backgroundColor = .black
        setUpViews()
        handleViewTapObservation(add: true)
    }
    
    //MARK: Check here for story
    fileprivate func addMyImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.imageOnMainQueue(image: UIImage(named: "userFemaleBrunette")!)
            return
        }
        FirebaseController.fetchUserWithUID(userID: uid) { (theUser) in
            if theUser != nil {
                //User may not have image? add default
                StoryController.userHasStory(currentUID: theUser!.uid) { exists in
                    if exists == true {
                        print("Has story!")
                        //self.animateViewForMyStory()
                    }
                }
                self.myImageView.loadImage(urlString: theUser!.profileImageUrl)
            } else {
                self.imageOnMainQueue(image: UIImage(named: "userFemaleBrunette")!)
            }
        }
    }
    
    fileprivate func animateViewForMyStory() {
        //TODO imp.
    }
    
    fileprivate func imageOnMainQueue(image: UIImage) {
        DispatchQueue.main.async {
            self.myImageView.image = image;
        }
    }
    
    //Add on init, remove on deinit
    fileprivate func handleViewTapObservation(add: Bool) {
        if add == true {
            NotificationCenter.default.addObserver(self, selector: #selector(notificationWrapper(notification:)), name: NSNotification.Name(rawValue: viewTappedNotification), object: nil)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func notificationWrapper(notification: Notification) {
        Logger.log("--- NOTIF --- \(notification)")
    }
    
    fileprivate func clearScrollView() {
        for theView in viewArray {
            theView.removeFromSuperview()
        }
    }
    
    deinit {
        handleViewTapObservation(add: false)
    }
    
    fileprivate func setUpViews() {
        //set up scroll view
        scrollView = UIScrollView(frame: CGRect(x: 100, y: 10, width: self.contentView.frame.size.width - 110, height: 80))
        scrollView.contentSize = CGSize(width: contentView.frame.size.width * 2, height: 0)
        contentView.addSubview(scrollView)
        
        //set up my personal view
        myImageView = PostCellImageView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        myImageView.layer.cornerRadius = 40
        myImageView.layer.masksToBounds = true
        myImageView.backgroundColor = Colors().neptuneBlue
        
        myImageView.isUserInteractionEnabled = true
        let myImageTap = UITapGestureRecognizer(target: self, action: #selector(handleMyImageViewTap))
        myImageView.addGestureRecognizer(myImageTap)
        
        contentView.addSubview(myImageView)
        
        addMyImage()
    }
    
    //TODO set story array here
    
    func populateScrollView(array: [Story]) {
        viewArray.removeAll()
        clearScrollView()
        
        var x = CGFloat(0.0)
        
        for i in 0..<array.count {
            
            let dimension = CGFloat(self.frame.size.height - 30)
            let frameForSV = CGRect(x: x, y: CGFloat(5), width: dimension, height: dimension)
            let storyView = StoryView(frame: frameForSV)
            viewArray.append(storyView)
            
            stylize(theView: storyView, i: i)
            
            //Do I need to add :? Make sure it sends index with tap
            let tap = UITapGestureRecognizer(target: self, action: #selector(viewTappedAtIndex))
            storyView.addGestureRecognizer(tap)
            
            let quarter = dimension / 4
            let cornerFAKContainer = UIImageView(frame: CGRect(x: (quarter * 3) + x, y: 5, width: quarter, height: quarter))
            cornerFAKContainer.layer.cornerRadius = quarter / 2
            cornerFAKContainer.layer.masksToBounds = true
            cornerFAKContainer.layer.borderWidth = 1
            cornerFAKContainer.layer.borderColor = UIColor.white.cgColor
            cornerFAKContainer.image = UIImage.fontAwesomeIcon(name: .flipboard, style: .brands, textColor: .white, size: CGSize(width: quarter, height: quarter))
            cornerFAKContainer.backgroundColor = .cyan
            cornerFAKContainer.isUserInteractionEnabled = true
            cornerFAKContainer.tag = i
            
            let flipTap = UITapGestureRecognizer(target: self, action: #selector(flipTappedAtIndex(sender:)))
            cornerFAKContainer.addGestureRecognizer(flipTap)
            
            //Add label?
            scrollView.addSubview(storyView)
            scrollView.addSubview(cornerFAKContainer)
            
            x = x + (dimension + 5)
        }
    }
    
    fileprivate func stylize(theView: UIView, i: Int) {
        theView.layer.cornerRadius = 35
        theView.tag = i
        theView.isUserInteractionEnabled = true
    }
    
    //Better to have parent / child relationship than do this?
    fileprivate func storyViewAtIndex(i: Int) -> StoryView? {
        var found = false
        var returnView : StoryView?
        for theView in viewArray {
            if theView.tag == i {
                found = true
                returnView = theView
            }
        }
        return found == true ? returnView : nil
    }
    
    //To flip cell
    @objc func flipTappedAtIndex(sender: UITapGestureRecognizer) {
        
        //MARK: Flipping child view (story view)
        let smallFAKView = sender.view!
        guard let storyView = storyViewAtIndex(i: smallFAKView.tag) else {
            Logger.log("No story view")
            return
        }
        
        storyView.backgroundColor = .clear // clear out while flipping (not working, look into)
        if storyView.isFlipped == true {
            UIView.transition(with: storyView, duration: 0.5, options: .transitionFlipFromRight) {
                storyView.isFlipped = false
            }
        } else {
            UIView.transition(with: storyView, duration: 0.5, options: .transitionFlipFromLeft) {
                storyView.isFlipped = true
            }
        }
        
        //MARK: Flipping self (may want to do externally via delegate or something?)
    }
    
    //To view story in feed VC
    @objc func viewTappedAtIndex(sender: StoryView) {
        //Logger.log("--- sender.tag \(String(describing: sender.tag))")
        
        //TODO fetch story
        
        //self.delegate?.storyViewTappedWithStory(story: )
    }
    
    @objc func handleMyImageViewTap() { //To add a new story, adding profile pic will be in my feed VC
        self.delegate?.mainImageTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //String ??
    func viewSelectedAtIndex(index: String) {
        
    }
}

//TODO load stories as they appear on screen in scrollview did scroll

extension StoriesHeaderCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // find view index and load accordingly
    }
}
