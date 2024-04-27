//
//  AppDelegate.swift
//  CameraApp
//
//  Created by Etka Uzun on 23.04.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // When app is killed durring session or quickly after session this code runs before
        // all images are saved which results in not deleted images.
        // Needs investigation.
        StoredImageManager.shared.deleteAllImages()
    }
}

