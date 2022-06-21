//
//  FindMyFriendsViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 11/30/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import MapKit

class FindMyFriendsViewController: UIViewController {

    let circleAnimation : CirclePulsateAnimation = {
        let ca = CirclePulsateAnimation()
        return ca
    }()
    
    lazy var mapView : MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    //Will cover the map view and fade away as orbs animat, should subclass and add star effect
    let spaceOverlay : UIView = {
        let spaceOverlay = UIView()
        spaceOverlay.backgroundColor = .black
        return spaceOverlay
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewSetup()
    }
    
    //TODO MapView will animate in from back with a space background, but will just put here as is for now
    fileprivate func viewSetup() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        mapView.delegate = self
        
        //Fade away animation
        spaceOverlay.frame = self.view.frame
        view.addSubview(spaceOverlay)
        UIView.animate(withDuration: 3) {
            self.spaceOverlay.alpha = 0
        } completion: { finished in
            self.spaceOverlay.removeFromSuperview()
        }

        circleAnimation.frame = circleFrame()
        circleAnimation.layer.cornerRadius = circleFrame().size.width / 2
        view.addSubview(circleAnimation)
    }
    
    fileprivate func circleFrame() -> CGRect {
        let vw = view.frame.size.width
        let vh = view.frame.size.height
        return CGRect(x: 10, y: vh / 4, width: vw - 20, height: vw - 20)
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

//typealias because we may add more
typealias MapDelegate = MKMapViewDelegate

extension FindMyFriendsViewController: MapDelegate {
    
}
