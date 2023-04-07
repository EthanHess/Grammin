//
//  HomePostTableViewCell.swift
//  Grammin
//
//  Created by Ethan Hess on 9/5/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import AVKit
import FirebaseStorage

protocol HomePostCellDelegate : class {
    func commentTapped(post: Post)
    func likeTapped(for cell: HomePostCollectionViewCell)
    func postPopupWithImage(image: UIImage)
    //TODO add video func. for this
}

class HomePostCollectionViewCell: UICollectionViewCell {
    
    //TODO add and cancel / only load when on screen for smooth table
    var downloadTasks : [StorageDownloadTask] = []
    
    //Subviews
    let userProfileImageView : PostCellImageView = {
        let iv = PostCellImageView()
        iv.image = UIImage(named: "userFemaleBrunette")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    
    //TODO placeholder?
    let mainImageView : PostCellImageView = {
        let iv = PostCellImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //TODO change images
    
    //NOTE: iOS update threw these warnings, fix this (self needs to surely exist here so add target after initialization)
    
    //'self' refers to the method 'HomePostCollectionViewCell.self', which may be unexpected
    var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "likeEmpty")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chatEmpty")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    var stackView : UIStackView = {
        let theStack = UIStackView()
        return theStack
    }()
    
    //May want a custom subclass with scrollView + custom view since this could potentially cause problems? Determine after tests.
    
    //TODO display if comments
    lazy var commentsTable : UITableView = {
        let ct = UITableView()
        return ct
    }()
    
    //TODO: Config AVPlayer and multiple image scheme
    
    //Delegate
    
    weak var delegate: HomePostCellDelegate?
    
    var gridMode : Bool? {
        didSet {
            gridUpdates()
        }
    }
    
    var applyCardLayout : Bool? {
        didSet {
            //TODO?
        }
    }
    
    //MARK: Multiple images / videos setup
    lazy var multipleScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    var viewArrayMultiple: [UIView] = []
    lazy var multipleCounterLabel: UILabel = {
        let cl = UILabel()
        return cl
    }()
    
    var post : Post? {
        didSet {
            
            guard let postID = post?.postID else {
                Logger.log("Something went wrong")
                return
            }
            
            UIConfigOnPostSet()
            LikeController.postLiked(likerUID: post!.postAuthor.uid, postID: postID) { liked in
                DispatchQueue.main.async {
                    self.configureLike(liked: liked)
                }
            }

            if post?.multiple == true {
                //0.25 delay makes sure frame is not 0.0 but probably better to do this in some sort of "set" function rather than hardcoding due to unpredictability.
                perform(#selector(setUpForMultiple), with: nil, afterDelay: 0.25)
            } else {
                multipleScrollView.removeFromSuperview()
            }
            
            guard let postImageUrl = post?.imageURL else { return }
            mainImageView.loadImage(urlString: postImageUrl)
        }
    }
    
    //Selectors
    
    fileprivate func gestureRecognizerForView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(postTapHandlerForDelegate))
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func postTapHandlerForDelegate() {
        guard let theImage = self.mainImageView.image else {
            return
        }
        self.delegate?.postPopupWithImage(image: theImage)
    }
    
    fileprivate func configureLike(liked: Bool) {
        let imageEmpty = UIImage(named: "likeEmpty") //Check snapshot here or do in main VC?
        let imageFilled = UIImage(named: "likeFilled")
        likeButton.setImage(liked == true ? imageFilled?.withRenderingMode(.alwaysOriginal) : imageEmpty?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    //Setup needed for either single or multiple
    fileprivate func UIConfigOnPostSet() {
        usernameLabel.text = ""
        usernameLabel.text = post?.postAuthor.username
        
        gestureRecognizerForView()
        
        guard let theUID = post?.postAuthor.uid else { Logger.log(""); return }
        //Originally had user object attached to post but this may be more efficient
        
        //TODO cache
        FirebaseController.fetchUserWithUID(userID: theUID) { (user) in
            guard let theUser = user else { return }
            self.userProfileImageView.loadImage(urlString: theUser.profileImageUrl)
            self.setAttributedCaption(user: theUser)
        }
    }
    
    //May be better to subclass scroll view but also want to avoid nested delegation
    @objc fileprivate func setUpForMultiple() {
        guard let thePost = post else { return }
        //We know "post" exists here
        let width = mainImageView.frame.size.width
        multipleScrollView.frame = mainImageView.bounds
        let size = CGSizeMake(width * CGFloat(thePost.mediaArray.count), 0)
        multipleScrollView.contentSize = size
        multipleScrollView.delegate = self
        
        //Just a test, ideally should hide miv and add scroll view to content view, this is not ideal
        mainImageView.addSubview(multipleScrollView)
        
        clearScrollView()
        
        //MARK: NOTE Should load images / video when appears onscreen, not efficient at all to do this but just seeing what it looked like
        
        let height = multipleScrollView.frame.size.height
        var xCoord : CGFloat = 0
        for i in 0..<thePost.mediaArray.count {
            let mediaItem = thePost.mediaArray[i]
            let frame = CGRect(x: xCoord, y: 0, width: width, height: height)
            let imageView = PostCellImageView(frame: frame)
            if subItemIsImage(mediaItem) == true {
                imageView.loadImage(urlString: mediaItem)
                imageView.tag = i //Add gesture eventually
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
            } else {
                //TODO add AVPlayer here for video and monitor when it comes on screen (play / pause)
                
                //TODO start player when on screen and play if tapped
                if let videoURL = URL(string: mediaItem) {
                    let player = AVPlayer(url: videoURL)
                    let layer = AVPlayerLayer(player: player)
                    layer.videoGravity = .resize
                    layer.frame = imageView.bounds
                    imageView.layer.addSublayer(layer)
                }
            }
            
            viewArrayMultiple.append(imageView)
            multipleScrollView.addSubview(imageView)
            
            xCoord += width
        }
    }
    
    fileprivate func clearScrollView() {
        viewArrayMultiple.removeAll()
        for subview in multipleScrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    //Eventually want an object w / enum but just a test
    fileprivate func subItemIsImage(_ str: String) -> Bool {
        return str.contains("image")
    }
    
    
    fileprivate func gridUpdates() {
        stackView.isHidden = self.gridMode!
    }
    
    fileprivate func setAttributedCaption(user: User) {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " \(post.bodyText)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.timestamp.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        
        captionLabel.attributedText = attributedText
    }
    
    fileprivate func configureMedia() {
        //Ad player layer for video view
    }
    
    @objc func handleLike() {
        Logger.log("Liking")
        delegate?.likeTapped(for: self)
    }
    
    fileprivate func resetLikeButton(_ likedAlready: Bool) {
        let imageEmpty = UIImage(named: "likeEmpty") //Check snapshot here or do in main VC?
        let imageFilled = UIImage(named: "likeFilled")
        likeButton.setImage(likedAlready == true ? imageEmpty?.withRenderingMode(.alwaysOriginal) : imageFilled?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    fileprivate func likeBounceAnimation() {
        
    }
    
    @objc func handleComment() {
        Logger.log("Commenting")
        guard let post = post else { return }
        delegate?.commentTapped(post: post)
    }
    
    fileprivate func presentCommentField() {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        uiConfig()
    }
    
    fileprivate func uiConfig() {
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        //self.layer.masksToBounds = true
        //content view?
        
        //self.backgroundColor = UIColor.fromRGB(red: 48.0, green: 75.0, blue: 191.0)
        self.backgroundColor = .clear //Collection View BG should be cool space image, not too much to take away from feed pictures though
        
        self.layer.shadowColor = UIColor.fromRGB(red: 200.0, green: 245.0, blue: 239.0).cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
    
    //Content View?
    fileprivate func addSubviews() {
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(mainImageView)
        
        anchors()
    }
    
    fileprivate func anchors()  {
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: mainImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: mainImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        mainImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        mainImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setUpActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        setUpActionButtons()
    }
    
    fileprivate func setUpActionButtons() {
        stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: mainImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: mainImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //TODO uncomment for card deck, or move to different cell class?
        
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if self.applyCardLayout == true {
            let circularlayoutAttributes = layoutAttributes as! LayoutAttributes
            self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
            self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Generally want to cancel the network call when cell scrolls offscreen (i.e. user is scrolling really fast and if calls aren't cancelled table could get laggy / slow)
        
        //Can have task property and cancel task (or tasks if multiple when cell dequeues)
    }
}


extension HomePostCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Update counter label here
    }
}
