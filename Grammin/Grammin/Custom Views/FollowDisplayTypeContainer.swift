//
//  FollowDisplayTypeContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 11/8/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

protocol FollowDisplayDelegate : class {
    func optionsTappedAtIndex(index: Int)
}

//Options in following VC
class FollowDisplayTypeContainer: UICollectionReusableView {

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    weak var delegate: FollowDisplayDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var viewArray : [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //View setup after frame is set
    fileprivate func setUpViews() {
        viewArray.removeAll()
        clearScrollView()
        
        let vw = self.frame.size.width
        let vh = self.frame.size.height
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: vw, height: vh))
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: vw * 2, height: 0)
        self.addSubview(scrollView)
        
        var x = CGFloat(0.0)
        
        for i in 0..<followingOptions().count {
            
            let dimension = CGFloat(labelWidth())
            let frameForLabel = CGRect(x: x, y: CGFloat(5), width: dimension, height: 50)
            let label = UILabel(frame: frameForLabel)
            
            label.text = followingOptions()[i]
            labelStylize(label: label)
            label.tag = i
            
            //Do I need to add :? Make sure it sends index with tap
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTappedAtIndex))
            label.addGestureRecognizer(tap)
            
            scrollView.addSubview(label)
            viewArray.append(label)
            
            x = x + dimension
        }
    }
    
    //TODO add emoticon?
    fileprivate func labelStylize(label: UILabel) {
        label.layer.cornerRadius = label.frame.size.height / 2
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
    }
    
    //Do we need this?
    fileprivate func clearScrollView() {
        for theView in viewArray {
            theView.removeFromSuperview()
        }
    }
    
    fileprivate func labelWidth() -> CGFloat {
        let vw = self.frame.size.width / 3
        return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) == true ? vw : vw / 2
    }
    
    //TODO subclass these labels?
    fileprivate func followingOptions() -> [String] {
        return ["All", "Following", "Top Accounts", "Top Events", "Top Hashtags", "Top Posts"]
    }
    
    @objc func labelTappedAtIndex(sender: UIGestureRecognizer) {
        self.delegate?.optionsTappedAtIndex(index: sender.view!.tag)
    }
    
    //TODO have toggle below this view to have sub options view, i.e. top posts will have categories like science, arts, food etc.
    
    //MARK: ScrollView delegate
    
}


extension FollowDisplayTypeContainer: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Logger.log("SV CONTENT OFFSET IN FDTC \(scrollView.contentOffset.x)")
        //expandShrinkSubviewsAccordinly(scrollView.contentOffset.x)
    }
    
    //MARK: TODO finish this + add shadow
    fileprivate func expandShrinkSubviewsAccordinly(_ offset: CGFloat) {
        let vw = self.frame.size.width
        let oneThird = vw / 3
        //MARK: 0, content is all the way right, 1 / 3 of vw, second label will be all the way right, etc.
        
        //Will eventually be a more gradual animation point by point but do this for now
        if (offset < oneThird) { //First label larger
            let theLabel = viewArray[0]
            expandShrinkHelperFunction(theLabel, true)
        }
        
        if (offset < oneThird * 2 && offset > oneThird) {
            let theLabel = viewArray[1]
            expandShrinkHelperFunction(theLabel, true)
        }
    }
    
    fileprivate func expandShrinkHelperFunction(_ label: UILabel, _ expand: Bool) {
        //UIView block with very low animation duration?
        let xCoord = label.frame.origin.x
        let yCoord = expand == true ? 1 : 5
        let theWidth = labelWidth()
        let theHeight = expand == true ? 58 : 50
        let newFrame = CGRect(x: xCoord, y: CGFloat(yCoord), width: theWidth, height: CGFloat(theHeight))
        label.frame = newFrame
    }
}
