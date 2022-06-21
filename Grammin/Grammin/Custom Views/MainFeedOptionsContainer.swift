//
//  MainFeedOptionsContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 2/1/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

protocol MainFeedOptionsContainerDelegate : class {
    func viewTappedWithTag(_ tag: Int)
}

class MainFeedOptionsContainer: UIView {

    weak var delegate : MainFeedOptionsContainerDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        //viewSetup()
    }
    
    func setUpViewsPublic() {
        viewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //TODO animate onto screen?
    fileprivate func viewSetup() {
        
        self.isUserInteractionEnabled = true
        
        if self.subviews.count > 0 {
            return;
        }
        
        //MARK: Avoid index / range crashes if two arrays but we should just use one
        // assert(titleArray().count == colorArray().count)
        
        for i in 0...nameColorMappingDictArray().count - 1 {
            let dictAtIndex = nameColorMappingDictArray()[i]
            let dictTitle = dictAtIndex.keys.first
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
            let tens = i + 10
            let height = frame.size.height / 10
            let theFrame = CGRect(x: 10, y: (height * CGFloat(i)) + CGFloat(tens), width: frame.size.width - 20, height: height)
            let theLabel = UILabel(frame: theFrame)
            theLabel.tag = i //NOTE is assigning last index to all of them, maybe have separate gesture rec?
            theLabel.isUserInteractionEnabled = true
            theLabel.textAlignment = .center
            //theLabel.text = titleArray()[i]
            theLabel.text = dictTitle
            theLabel.addGestureRecognizer(gesture)
            let subDictAtIndex = dictAtIndex[dictTitle ?? ""] ?? ["": UIColor.blue]
            theLabel.textColor = subDictAtIndex["color"] as? UIColor
            theLabel.backgroundColor = .clear
            theLabel.numberOfLines = 0
            radiusHandler(theView: theLabel, color: UIColor.mainBlue())
            self.addSubview(theLabel)
        }
    }
    
    fileprivate func radiusHandler(theView: UIView, color: UIColor) {
        theView.layer.cornerRadius = 3;
        theView.layer.borderColor = color.cgColor
        theView.layer.masksToBounds = true
        theView.layer.borderWidth = 1
    }
    
    @objc fileprivate func tapHandler(sender: UITapGestureRecognizer) {
        
        guard let theView = sender.view else {
            Logger.log("No view")
            return
        }
        let tag = theView.tag
        Logger.log("Tag \(tag)")
        
        self.delegate?.viewTappedWithTag(tag)
    }

    //TODO add events + Tinder style swipe
    
    
    //MARK: Can discard these
    
//    fileprivate func titleArray() -> [String] {
//        return ["Trending", "Friend Finder", "Liked", "Live", "Activity", "Jobs", "Housing"]
//    }
//
//    //TODO custom, different types of blue
//    fileprivate func colorArray() -> [UIColor] {
//        return [UIColor.cyan, UIColor.magenta, UIColor.mainBlue(), UIColor.cyan, UIColor.magenta, UIColor.green, UIColor.orange]
//    }
    
    //MARK: Should ideally be "Any", but that is throwing warnings, for example, a String cannot be "AnyObject" as it does not conform to the protocol
    typealias ItemInfo = [String: AnyObject]
    typealias NameColorDict = [String : ItemInfo]
    
    //MARK: This will replace original arrays, better to have all in one place
    fileprivate func nameColorMappingDictArray() -> [NameColorDict] {
        let dictOne = ["Events": ["color": UIColor.cyan, "image": UIImage(named: "")]]
        let dictTwo = ["Services": ["color": UIColor.magenta, "image": UIImage(named: "")]]
        let dictThree = ["Friend Finder": ["color": UIColor.systemGreen, "image": UIImage(named: "")]]
        
        //MARK: Test to see if it works with a string
        //let testDict = ["Strings": ["color": "Blue", "image": "some_image"]]
        
        //MARK: TODO add others from list as well as "Create" + "Manage" button
        return [dictOne, dictTwo, dictThree] as [NameColorDict]
    }
    
    //For background effect
    fileprivate func textureArray() -> [UIImage] {
        let imageOne = UIImage(named: "")
        let imageTwo = UIImage(named: "")
        let imageThree = UIImage(named: "")
        let imageFour = UIImage(named: "")
        let imageFive = UIImage(named: "")
        guard let io = imageOne, let it = imageTwo, let ith = imageThree, let ifo = imageFour, let ifv = imageFive else {
            Logger.log("")
            return []
        }
        return [io, it, ith, ifo, ifv]
    }
}
