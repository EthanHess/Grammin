//
//  StoryContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 4/28/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import AVKit

class StoryContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
    
    //TODO add text + filters
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    func viewSetup() {
        addSubview(containerImage)
        containerImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func addImage(image: UIImage) {
        playerLayer.removeFromSuperlayer()
        self.containerImage.image = image
    }
    
    func videoSetup(url: URL) {
        self.player = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.frame = self.containerImage.bounds
        self.containerImage.layer.addSublayer(self.playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
