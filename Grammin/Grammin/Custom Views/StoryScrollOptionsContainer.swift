//
//  StoryScrollOptionsContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 4/26/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

//TODO add delegation here

import UIKit

class StoryScrollOptionsContainer: UIView {
    
    //Toggle text or BG color, or filter color?
    //https://stackoverflow.com/questions/25448879/how-do-i-take-a-full-screen-screenshot-in-swift
    
    //FILTER
    //https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    
    //This will control font attributes
    let textChoiceView : StoryTextContainer = {
        let tcv = StoryTextContainer()
        return tcv
    }()
    
    //TODO add delegates
    let colorChoiceView : StoryColorChoiceView = {
        let ccv = StoryColorChoiceView()
        return ccv
    }()
    
    let filterChoiceView : StoryFilterChoiceView = {
        let fcv = StoryFilterChoiceView()
        return fcv
    }()
    
    let scrollView : UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Text should be first?
        
        //Is CGRectZero here, wait to call
        //scrollSetup()
    }
    
    func scrollSetupWrapper() {
        scrollSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func scrollSetup() {
        self.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        
        addSubview(scrollView)
        scrollView.frame = self.bounds
        cornerRadiusForView(view: scrollView, borderColor: .white)
        scrollView.isPagingEnabled = true //snap
        scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
        
        scrollView.addSubview(textChoiceView)
        scrollView.addSubview(colorChoiceView)
        scrollView.addSubview(filterChoiceView)
        
        let w = frame.size.width
        textChoiceView.frame = CGRect(x: 3, y: 3, width: w - 6, height: frame.size.height - 6)
        cornerRadiusForView(view: textChoiceView, borderColor: .white)
        colorChoiceView.frame = CGRect(x: w + 3, y: 3, width: w - 6, height: frame.size.height - 6)
        cornerRadiusForView(view: colorChoiceView, borderColor: .white)
        filterChoiceView.frame = CGRect(x: (w * 2) + 3, y: 3, width: w - 6, height: frame.size.height - 6)
        cornerRadiusForView(view: filterChoiceView, borderColor: .white)
        
        //cornerRadiusForView(view: self, borderColor: .white)
    }
    
    //TODO custom
    fileprivate func cornerRadiusForView(view: UIView, borderColor: UIColor) {
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.layer.borderColor = borderColor.cgColor
    }
}

extension StoryScrollOptionsContainer: UIScrollViewDelegate {
    //TODO add custom paging enabled with animation for each
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
