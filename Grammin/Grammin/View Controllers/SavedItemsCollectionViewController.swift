//
//  SavedItemsCollectionViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 1/12/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit

class SavedItemsCollectionViewController: UIViewController {

    lazy var dismissButton: UIBarButtonItem = { //should be toggle skill button
        let theButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDismiss))
        return theButton
    }()
    
    //Will not be UICollectionViewController for better UI versatility
    lazy var theCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CircularLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.layer.borderColor = UIColor.white.cgColor
        collectionView.layer.borderWidth = 1
        collectionView.layer.masksToBounds = true
        return collectionView
    }()
    
    //Saved posts - should rename?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO space animations + circular/card collection
        self.view.backgroundColor = .black
        self.navigationItem.leftBarButtonItem = dismissButton
        
        registerCollection()
    }
    
    fileprivate func fetchSavedPosts() {
        //For now just passing posts from previous VC to test UI
    }
    
    //For now, add button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func registerCollection() {
//        collectionView?.register(MyProfileMediaCell.self, forCellWithReuseIdentifier: "cellId")
        theCollectionView.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: "homePostCellId")
        collectionSetup()
        
        //TODO do in fetch posts
        refreshCollection()
    }
    
    fileprivate func collectionSetup() {
        view.addSubview(theCollectionView)
        theCollectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: view.frame.size.width - 40, height: view.frame.size.height - 150)
    }
    
    fileprivate func refreshCollection() {
        theCollectionView.reloadData()
    }
    
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //TODO scene kit + refer to github
    fileprivate func spaceColorArray() -> [UIColor] {
        let spaceOne = UIColor(red: 241, green: 92, blue: 171, alpha: 1)
        let spaceTwo = UIColor(red: 175, green: 241, blue: 197, alpha: 1)
        let spaceThree = UIColor(red: 241, green: 191, blue: 175, alpha: 1)
        let spaceFour = UIColor(red: 240, green: 241, blue: 175, alpha: 1)
        let spaceFive = UIColor(red: 235, green: 241, blue: 245, alpha: 1)
        let spaceSix = UIColor(red: 44, green: 156, blue: 241, alpha: 1)
        return [spaceOne, spaceTwo, spaceThree, spaceFour, spaceFive, spaceSix]
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


extension SavedItemsCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    //TODO use different cell?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MyProfileMediaCell
//            cell.post = posts[indexPath.item]
//            return cell
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homePostCellId", for: indexPath) as! HomePostCollectionViewCell
            cell.applyCardLayout = true
            cell.gridMode = true //To hide certain subviews
            cell.post = posts[indexPath.item]
        
            return cell
        
    }
}
