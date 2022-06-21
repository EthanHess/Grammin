//
//  SelectPhotoViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 3/14/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import QBImagePickerController

struct ChosenItem : Equatable {
    let mediaType : String?
    let downloadURL : String?
    let index : Int
}

struct CollectionItem : Equatable {
    let media : String? //Could be bool if only two options
    let image : UIImage?
    let video : URL? //This will be asset's url
}

//MARK: Will replace select photo collection view
class SelectPhotoViewController: UIViewController {

    //MARK: Properties
    lazy var imageCollectionView : UICollectionView = { //Could just be "Media", may include videos
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderColor = UIColor.white.cgColor
        collectionView.layer.borderWidth = 1
        collectionView.layer.masksToBounds = true
        return collectionView
    }()
    
    //MARK: Now that we're no longer using MIS, this can be a scroll (NOTE: Should there be an option to change media type (i.e. only videos / images etc.)) ?
    
    var selectButton : UIButton = {
        let sb = UIButton()
        sb.setTitle("Select Media", for: .normal)
        sb.addTarget(self, action: #selector(customPickerPresent), for: .touchUpInside)
        sb.setTitleColor(.white, for: .normal)
        return sb
    }()
    
    //MARK: Replacing above, this will go on top of the collection view
    var chosenAssetsView : ChosenAssetsScrollView = {
        let cav = ChosenAssetsScrollView()
        return cav
    }()
    
    var draftsButton : UIButton = {
        let dbt = UIButton()
        dbt.setTitle("Drafts", for: .normal)
        dbt.addTarget(SelectPhotoViewController.self, action: #selector(draftTappedHandler), for: .touchUpInside)
        dbt.setTitleColor(.white, for: .normal)
        dbt.layer.cornerRadius = 10
        dbt.layer.borderColor = UIColor.white.cgColor
        dbt.layer.borderWidth = 1
        dbt.layer.masksToBounds = true
        return dbt
    }()
    
    //MARK: For now will just use PHAsset for images/video/audio whatever to not rely on a 3rd party framwork
    lazy var multipleImageSelector: QBImagePickerController = {
        let ip = QBImagePickerController()
        ip.delegate = self
        ip.allowsMultipleSelection = true
        ip.maximumNumberOfSelection = 6
        ip.showsNumberOfSelectedAssets = true
        return ip
    }()
    
    let mainCell = "mainCell"
    let draftCell = "draftCell"
    
    var selectedImage: UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    var chosenAssets = [PHAsset]()
    
    var chosenImages : [UIImage] = []
    var chosenVideoURL : URL?
    var chosenVideoURLs : [URL] = []
    
    var downloadURLArrays : [String] = []
    
    //var chosenItems : [ChosenItem] = []
    var chosenItems : [CollectionItem] = []
    var collectionItems : [CollectionItem] = [] // For display
    
    lazy var dismissButton: UIBarButtonItem = { //should be toggle skill button
        let theButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDismiss))
        return theButton
    }()
    
    //MARK: Flow
    
    //Toggle single or multi, have bar to view drafts under collection view (top half of screen)
    //Can also select multiple drafts (incl. video)
    //Have option to apply filter?
    //Pass to filter VC which will then go to post VC
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationSetup()
        self.view.backgroundColor = .black
    }
    
    //MARK: Grabbing users local images/videos etc. (Can move this to utils class)
    //MARK: NOTE: Check performance, this will potentially fetch thousands of items on real device
    
    fileprivate func loadImages() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
//        let allAudio = PHAsset.fetchAssets(with: .audio, options: assetsFetchOptions()) //Should eventually have "share audio" function?
        
        collectionItems.removeAll()
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                let imageManager = PHImageManager.default()
                
                //MARK: Trying to access both videos + images simultaneaously fails, do after images are gotten or vice versa
                if allPhotos.count > 0 {
                allPhotos.enumerateObjects({ (asset, count, stop) in
                    let targetSize = CGSize(width: 200, height: 200)
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                        if let image = image {
                            self.images.append(image)
                            self.assets.append(asset)
                            
                            let collectionItem = CollectionItem(media: "image", image: image, video: nil)
                            self.collectionItems.append(collectionItem)
                            
                            if self.selectedImage == nil {
                                self.selectedImage = image
                            }
                        }
                        if count == allPhotos.count - 1 {
                            self.loadVideos(imageManager: imageManager)
                        }
                        //MARK: Original, pre-video reload, do we still need to factor in count?
//                        if count == allPhotos.count - 1 {
//                            self.reload()
//                        }
                    })
                })
                } else {
                    self.loadVideos(imageManager: imageManager)
                }
            }
        }
    }
    
    //Add to utils class?
    fileprivate func loadVideos(imageManager: PHImageManager) {
        let allVideos = PHAsset.fetchAssets(with: .video, options: assetsFetchOptions())
        if allVideos.count > 0 {
            let dispatchGroup = DispatchGroup()
            allVideos.enumerateObjects { (asset, count, stop) in
            dispatchGroup.enter()
            self.assets.append(asset)
            imageManager.requestAVAsset(forVideo: asset, options: nil) { asset, audioMix, info in
                if let theAsset = asset  {
                    let urlAsset = theAsset as! AVURLAsset
                    let collectionItem = CollectionItem(media: "video", image: nil, video: urlAsset.url)
                    self.collectionItems.append(collectionItem)
                    dispatchGroup.leave()
                } else {
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                if count == allVideos.count - 1 {
                    self.reload()
                }
            }
            }
        } else {
            self.reload()
        }
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30 //Update? Could paginate this
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func navigationSetup() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextHandler))
        registerCollectionView()
    }
    
    
    //TODO adjust for iPad
    fileprivate func registerCollectionView() {
        
        let itemWidth = view.frame.size.width - 40
        let itemHeight = view.frame.size.height - 250
        
        //Top scroll for selected items
        self.view.addSubview(chosenAssetsView)
        chosenAssetsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 20, paddingBottom: 100, paddingRight: 20, width: itemWidth, height: 100)
        
        //Drafts button
        self.view.addSubview(draftsButton)
        draftsButton.anchor(top: chosenAssetsView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: itemWidth, height: 50)
        
        //Register cell
        imageCollectionView.register(ChooseMediaCollectionViewCell.self, forCellWithReuseIdentifier: mainCell)
        
        self.view.addSubview(imageCollectionView)
        imageCollectionView.anchor(top: draftsButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: itemWidth, height: itemHeight) //TODO diff. height value
        
        loadImages()
    }
    
//    fileprivate func stylizeUIView(theView: UIView, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, bgColor: UIColor) {
//        theView.layer.cornerRadius = cornerRadius
//        theView.layer.borderWidth = borderWidth
//        theView.layer.borderColor = borderColor.cgColor
//        theView.backgroundColor = bgColor
//        theView.layer.masksToBounds = true
//    }
    
    //MARK: Can remove?
    fileprivate func addButton() {
        self.view.addSubview(selectButton)
        selectButton.anchor(top: imageCollectionView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    }
    
    //MARK: Functions
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Will now go to filter VC
    @objc fileprivate func nextHandler() {
        let sharePhotoController = SharePhotoViewController()
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc fileprivate func customPickerPresent() {
        present(multipleImageSelector, animated: true, completion: nil)
    }
    
    @objc fileprivate func draftTappedHandler() {
        
    }
    
    fileprivate func reload() {
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
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

extension SelectPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    //2 for now, 1 for chosen images, another for drafts
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //TODO update for section
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCell, for: indexPath) as! ChooseMediaCollectionViewCell
    
        //Fatal index out of range happened here with 0 count, or count higher than IP, look into but this will do for now
        if collectionItems.count > indexPath.row - 1 {
            let item = collectionItems[indexPath.row]
        
            //MARK: Should use Fontawesome / SVGs for images, this one looks bad (quality wise)?
            cell.checkmarkImage.isHidden = !itemAlreadyExists(itemParam: item)
            cell.collectionItem = item
            cell.backgroundColor = .darkGray
            Logger.log("-- ITEM AT IP -- \(item)")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //If top, remove from array, if bottom, add draft
    
        let item = collectionItems[indexPath.row]
        let existsAlready = itemAlreadyExists(itemParam: item)
        
        //MARK: TODO add checkmark
        if existsAlready { //Remove from top scroll
            print("ITEM EXISTS \(item)")
            guard let index = chosenItems.index(of: item) else {
                return
            }
            chosenItems.remove(at: index) //Make sure IP will always correlate with item index in array
        } else { //Add to top scroll
            print("ITEM DOES NOT EXISTS \(item)")
            chosenItems.append(item)
        }
        
        //Present alert here?
        chosenAssetsView.configureScrollWithItems(items: chosenItems)
        self.reload()
    }
    
    //NOTE: Does not work for true yet
    fileprivate func itemAlreadyExists(itemParam: CollectionItem) -> Bool {
        return chosenItems.contains(itemParam)
    }
}

extension SelectPhotoViewController: UICollectionViewDelegateFlowLayout, QBImagePickerControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (imageCollectionView.frame.size.width / 2) - 9
        return CGSize(width: width, height: width)
    }
}
