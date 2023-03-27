//
//  PostCellImageView.swift
//  Grammin
//
//  Created by Ethan Hess on 9/6/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit

//make property?
var imageCache = [String: UIImage]()

class PostCellImageView: UIImageView {
    
    var lastURL : String?
    
    func loadImage(urlString: String) {
        self.lastURL = urlString
        self.image = nil
        
        if let cached = imageCache[urlString] {
            self.image = cached
            return //no need to proceed
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                Logger.log((error?.localizedDescription)!)
            } else {
                if url.absoluteString != self.lastURL {
                    return
                }
                guard let imageData = data else { return }
                if let photoImage = UIImage(data: imageData) {
                    imageCache[url.absoluteString] = photoImage
                    self.imageOnMainQueue(theImage: photoImage)
                }
            }
        }.resume()
    }
    
    fileprivate func imageOnMainQueue(theImage: UIImage) {
        DispatchQueue.main.async {
            self.image = theImage
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
