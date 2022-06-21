//
//  AppDelegate.swift
//  Grammin
//
//  Created by Ethan Hess on 5/21/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        appConfig(theApp: application)
        
        return true
    }
    
    func appConfig(theApp: UIApplication) {
        
        FirebaseApp.configure()
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        
        attempToRegisterForNotifs(app: theApp)
    }
    
    private func attempToRegisterForNotifs(app: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let options : UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (authGranted, error) in
            
            if error != nil {
                Logger.log("ERROR --- \(String(describing: error?.localizedDescription))")
            }
            
            if authGranted == true {
                Logger.log("AUTH SUCCESS!")
            } else {
                Logger.log("NO AUTH SUCCESS! :(")
            }
        }
    }
    
    //Xcode functions

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

//Messaging and notification delegates

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    //TODO set up custom logger
    
    //Set up
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Logger.log("DEVICE TOKEN \(deviceToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
    
    //Listen
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    //Handle user tapping on notification
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        guard let followerID = userInfo[""] as? String else { Logger.log("NO UID"); return }
        
        Logger.log("--- WE HAVE A FOLLOWER ID \(followerID)")
        
        let userPVC = UserProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        //TODO assign userID to userPVC
        
        guard let mainTBVC = window?.rootViewController as? MainTabBarController else {
            Logger.log("NO MTB");
            return
        }
        
        mainTBVC.selectedIndex = 0
        mainTBVC.presentedViewController?.dismiss(animated: true, completion: nil)
        
        if let homeVC = mainTBVC.viewControllers?.first as? UINavigationController {
            homeVC.pushViewController(userPVC, animated: true)
        }
    }
}

