//
//  AppDelegate.swift
//  bangumiSwift
//
//  Created by bi119aTe5hXk on 2019/02/03.
//  Copyright © 2019 bi119aTe5hXk. All rights reserved.
//

import UIKit
import OAuthSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("Init...")
        print("Powered by")
        print("██████╗  █████╗ ███╗   ██╗ ██████╗ ██╗   ██╗███╗   ███╗██╗")
        print("██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██║   ██║████╗ ████║██║")
        print("██████╔╝███████║██╔██╗ ██║██║  ███╗██║   ██║██╔████╔██║██║")
        print("██╔══██╗██╔══██║██║╚██╗██║██║   ██║██║   ██║██║╚██╔╝██║██║")
        print("██████╔╝██║  ██║██║ ╚████║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██║")
        print("╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝")
        print("Dev by ©bi119aTe5hXk & @xlfdll since 2019.")
        print("なにこれ(°Д°)？！")
        
        // Override point for customization after application launch.
//        let splitViewController = window!.rootViewController as! UISplitViewController
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//        splitViewController.delegate = self
        let userdefaults = UserDefaults.standard
        userdefaults.register(defaults: ["oauthtoken":""])
        userdefaults.synchronize()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey  : Any] = [:]) -> Bool {
        if (url.host == "oauth-callback") {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
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
    
    

    // MARK: - Split view

//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
//        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
//        if topAsDetailController.detailItem == nil {
//            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//            return true
//        }
//        return false
//    }

}

