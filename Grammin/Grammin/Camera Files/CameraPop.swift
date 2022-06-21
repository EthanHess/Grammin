//
//  CameraPop.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPop: UIViewController {
    
    //MARK: Poperties
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(capturePhotoHandler), for: .touchUpInside)
        return button
    }()
    
    //MARK: Custom classes
    let customPresenter : CustomPresenter = {
        let presenter = CustomPresenter()
        return presenter
    }()
    
    let customDismisser : CustomDismisser = {
        let dismisser = CustomDismisser()
        return dismisser
    }()
    
    let output = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        transitioningDelegate = self
        
        configureButtons()
        setupCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //@objc to be able to pass selector to add target in swift
    
    @objc func capturePhotoHandler() {
        Logger.log("-- Capturing photo ---")
        
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            Logger.log("No preview format type")
            return
        }
        
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    //fileprivate replaces private, only available in this code file
    
    fileprivate func configureButtons() {
        
        view.addSubview(dismissButton)
        view.addSubview(capturePhotoButton)
        
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    //Capture session setup
    fileprivate func setupCaptureSession() {
        
        let captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            Logger.log("AVCapture Error \(error.localizedDescription)")
        }
        
        //Add output to session
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraPop: AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    //VC transition
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.customDismisser
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.customPresenter
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //AV delegate
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        //If deprecated, try -[AVCapturePhoto fileDataRepresentation] instead?
        
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!) else {
            Logger.log("No image data")
            return
        }
        
        let previewImage = UIImage(data: imageData)
        Logger.log("IMAGE PREVIEW \(String(describing: previewImage))")
        
        let containerView = PhotoPreviewContainer()
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
