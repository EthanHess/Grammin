//
//  MainTabBarController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.delegate = self
        
        if hasUser() == false {
            DispatchQueue.main.async {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setUpVCs()
    }
    
    func hasUser() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func imageNamesArray() -> [String] {
        return ["homeUnselected", "homeSelected", "searchUnselected", "searchSelected", "plusUnselected", "plusSelected", "likeUnselected", "likeSelected", "womanUnselected", "womanSelected"]
    }
    
    func setUpVCs() { //TODO, set up custom layouts
        
        let homeLayout = UICollectionViewFlowLayout()
        let homeViewController = HomeViewController(collectionViewLayout: homeLayout)
        let unselectedHome = UIImage(named: imageNamesArray()[0])!.withRenderingMode(.alwaysOriginal)
        let selectedHome = UIImage(named: imageNamesArray()[1])!.withRenderingMode(.alwaysOriginal)
        
        //Home VC
        let homeVC = templateNavController(unselectedImage: unselectedHome, selectedImage: selectedHome, rootViewController: homeViewController)
        
        let searchLayout = UICollectionViewFlowLayout()
        
        //Search VC
        let searchVC = templateNavController(unselectedImage: UIImage(named: imageNamesArray()[2])!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: imageNamesArray()[3])!.withRenderingMode(.alwaysOriginal), rootViewController: UserSearchCollectionViewController(collectionViewLayout: searchLayout))
        
        let centerNavC = templateNavController(unselectedImage: UIImage(named: imageNamesArray()[4])!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: imageNamesArray()[5])!.withRenderingMode(.alwaysOriginal))
        let likesNavC = templateNavController(unselectedImage: UIImage(named: imageNamesArray()[6])!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: imageNamesArray()[7])!.withRenderingMode(.alwaysOriginal))
        
        //User's profile
        let userLayout = UICollectionViewFlowLayout()
        let userPFforNavC = UserProfileCollectionViewController(collectionViewLayout: userLayout)
        
        let userNavController = UINavigationController(rootViewController: userPFforNavC)
        
        userNavController.tabBarItem.image = UIImage(named: imageNamesArray()[8])!.withRenderingMode(.alwaysOriginal)
        userNavController.tabBarItem.selectedImage = UIImage(named: imageNamesArray()[9])!.withRenderingMode(.alwaysOriginal)
        
        tabBar.tintColor = .black
        
        viewControllers = [homeVC, searchVC, centerNavC, likesNavC, userNavController]
        
        guard let items = tabBar.items else {
            return
        }
        
        modifyItems(items: items) //Main queue?
    }
    
    //Controls image selection for Tab Bar
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
    
    func modifyItems(items: [UITabBarItem]) {
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainTabBarController: UITabBarControllerDelegate {
    
    //MARK: TB delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
        let vcIndex = viewControllers?.index(of: viewController)
        if vcIndex == 2 {
            
            //Config layout (OLD, DISC.)
//            let layout = UICollectionViewFlowLayout()
//            let photoSelectVC = SelectPhotoCollectionViewController(collectionViewLayout: layout)
            
            //New
            let photoSelectVC = SelectPhotoViewController()
            photoSelectVC.modalPresentationStyle = .fullScreen //Not working, is it becuase it's settings root vc below?
            let navController = UINavigationController(rootViewController: photoSelectVC)
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
