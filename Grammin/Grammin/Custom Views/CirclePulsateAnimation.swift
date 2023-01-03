//
//  CirclePulsateAnimation.swift
//  Grammin
//
//  Created by Ethan Hess on 12/6/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import FirebaseAuth

//Inspired by Shazam
class CirclePulsateAnimation: UIView {

    //lazy var = don't get created until they are needed and are only computed once, not thread safe so use sparingly
    
    lazy var mainImageView : PostCellImageView = {
        let iv = PostCellImageView()
        iv.backgroundColor = Colors().coolBlue
        return iv
    }()
    
    var viewArray : [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //delay so frame is set
        perform(#selector(viewSetup), with: nil, afterDelay: 0.25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Main frame of this view will be a circle covering the map view (or whatever other backdrop) with three subviews larger than the main image view to pulsate behind
    
    //Black diamond (for later) add liquid effect to circles so that edges are splash textured
    
    @objc fileprivate func viewSetup() {
        
        let inset = self.frame.size.width / 4
        let mainImageFrame = CGRect(x: inset, y: inset, width: inset * 2, height: inset * 2)
        
        viewArray.removeAll()
        
        //Add circles
        for i in 0...2 {
            //store original frame here?
            let circle = UIView(frame: mainImageFrame)
            circle.tag = i
            circle.backgroundColor = colorDict()[i]
            circle.layer.cornerRadius = inset
            self.addSubview(circle)
            viewArray.append(circle)
        }
        
        mainImageView.frame = mainImageFrame
        mainImageView.layer.cornerRadius = inset
        mainImageView.layer.masksToBounds = true
        mainImageView.image = UIImage(named: "userFemaleBrunette")
        self.addSubview(mainImageView)
        
        guard let theUID = Auth.auth().currentUser?.uid else { Logger.log("NO UID"); return }
        
        //TODO cache
        FirebaseController.fetchUserWithUID(userID: theUID) { (user) in
            guard let theUser = user else { return }
            self.mainImageView.loadImage(urlString: theUser.profileImageUrl)
        }
        
        startIntroAnimation()
    }
    
    fileprivate func colorDict() -> Dictionary<Int, UIColor> {
        return [0:.blue, 1:.cyan, 2:.green]
    }
    
    //Should be accessible from parent view?
    fileprivate func startIntroAnimation() {
        for i in 0...viewArray.count - 1 {
            let theView = viewArray[i]
            cabasicAnimationForView(theView, duration: Double(i) + 0.5, toVal: CGFloat(i + 2))
            
            //MARK: Can discard after test
            
//            UIView.animate(withDuration: Double(i) + 0.5) {
//                theView.transform = CGAffineTransform(scaleX: CGFloat(i + 1), y: CGFloat(i + 1))
//            } completion: { finished in
//                theView.transform = CGAffineTransform.identity
//            }
        }
    }
    
    fileprivate func cabasicAnimationForView(_ theView: UIView, duration: CGFloat, toVal: CGFloat) {
        let pulsate = CABasicAnimation(keyPath: "transform")
        pulsate.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        pulsate.toValue = NSValue(caTransform3D: CATransform3DMakeScale(toVal, toVal, toVal))
        pulsate.duration = duration
        pulsate.autoreverses = true
        //pulsate.repeatCount = 1 //defaults to 0
        theView.layer.add(pulsate, forKey: "transform")
    }
    
    fileprivate func endIntroAnimation() {
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
