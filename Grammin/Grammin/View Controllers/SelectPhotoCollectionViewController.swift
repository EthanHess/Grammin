//
//  SelectPhotoCollectionViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Photos
import QBImagePickerController

private let reuseIdentifier = "Cell"

//MARK: Will be replaced by select photo vc, but keep for reference temporarily
class SelectPhotoCollectionViewController: UICollectionViewController {
    
    //TODO add video functionality
    
    let mainCell = "cell"
    let mainHeader = "header"
    
    var selectedImage: UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    var chosenImages : [UIImage] = [] //for custom picker

    var chosenVideoURL : URL?
    var chosenVideoURLs : [URL] = []
    
    var downloadURLArrays : [String] = []
    
    var header: SelectPhotoHeader?
    
    lazy var multipleImageSelector: QBImagePickerController = {
        let ip = QBImagePickerController()
        ip.delegate = self
        ip.allowsMultipleSelection = true
        ip.maximumNumberOfSelection = 6
        ip.showsNumberOfSelectedAssets = true
        return ip
    }()
    
    lazy var dismissButton: UIBarButtonItem = { //should be toggle skill button
        let theButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDismiss))
        return theButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        navigationSetup()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        //self.navigationItem.leftBarButtonItem = dismissButton
        
        //NOTE: have tab with choice of one image or multiple
        //May want to not make this a collection VC for more versatility
        //customPickerTest()
    }
    
    fileprivate func customPickerTest() {
        present(multipleImageSelector, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func navigationSetup() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelHandler))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextHandler))
        registerCollectionView()
    }
    
    @objc fileprivate func cancelHandler() { //TODO take away done?
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Will need to pass image array if multi
    //MARK: Will also need to pass media type (i.e. video etc.)
    
    @objc fileprivate func nextHandler() {
        let sharePhotoController = SharePhotoViewController()
        sharePhotoController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    //MARK: Using QB may no longer need
    fileprivate func registerCollectionView() {
        collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: mainCell)
        collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: mainHeader)
        getPhotos()
    }
    
    fileprivate func reload() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCell, for: indexPath) as! SelectPhotoCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        reload()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    fileprivate func imageFromPHAsset(asset: PHAsset) -> UIImage? {
        var returnImage : UIImage? = nil
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 470, height: 470), contentMode: PHImageContentMode.aspectFill, options: options) { (image, info) in
            if image != nil {
                returnImage = image
            }
        }
        //Can be called before above set? Check
        return returnImage
    }

    // Can delete if we don't use it
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension SelectPhotoCollectionViewController {
    
    fileprivate func getPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                allPhotos.enumerateObjects({ (asset, count, stop) in
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 200, height: 200)
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                        if let image = image {
                            self.images.append(image)
                            self.assets.append(asset)
                            if self.selectedImage == nil {
                                self.selectedImage = image
                            }
                        }
                        if count == allPhotos.count - 1 {
                            self.reload()
                        }
                    })
                })
            }
        }
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30 //Update?
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
}

extension SelectPhotoCollectionViewController: UICollectionViewDelegateFlowLayout, QBImagePickerControllerDelegate {
    
    //QB TODO: add others?
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        //TODO add properties and convert to Swift
        
        if self.chosenVideoURL != nil {
            self.chosenVideoURL = nil
        }
        
        self.chosenImages.removeAll()
        
        //Remove video + downloadURL arrays too
        for asset in assets as! [PHAsset] {
            let imageFromAsset = imageFromPHAsset(asset: asset)
            if imageFromAsset != nil {
                //Add to array
            } else {
                //return / cancel
            }
        }
        
        if chosenImages.count == 1 {
            //TODO imp.
        }
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        //dismiss?
    }
    
    //Collection View
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainHeader, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        header.photoImageView.image = selectedImage
        
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
                    header.photoImageView.image = image
                })
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
}
