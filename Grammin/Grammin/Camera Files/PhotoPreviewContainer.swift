//
//  PhotoPreviewContainer.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Photos

class PhotoPreviewContainer: UIView {
    
    //MARK: Properties
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let imageOne = UIImage(named: "")
        button.setImage(imageOne!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        let imageTwo = UIImage(named: "")
        button.setImage(imageTwo!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    
    @objc func handleCancel() {
        self.removeFromSuperview() //main queue necessary?
    }
    
    @objc func handleSave() {
        
        Logger.log("Saving")
        
        //Have delegate present this alert from parent VC?
        
        guard let previewImage = self.previewImageView.image else {
            Logger.log("No preview image")
            return
        }
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, error) in
            if let tError = error {
                Logger.log(tError.localizedDescription)
                return
            }
            
            Logger.log("Saved!")
            
            DispatchQueue.main.async {
                
                let savedLabel = UILabel()
                self.addSavedLabel(savedLabel: savedLabel)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (complete) in

                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        savedLabel.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    func addSavedLabel(savedLabel: UILabel) {
        
        savedLabel.text = "Saved Successfully"
        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savedLabel.textColor = .white
        savedLabel.numberOfLines = 0
        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        savedLabel.textAlignment = .center
        
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = self.center
        
        self.addSubview(savedLabel)
        
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white //add custom white
        viewConfiguration()
    }
    
    func viewConfiguration() {
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
