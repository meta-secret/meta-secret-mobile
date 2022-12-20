//
//  AppDelegate.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.07.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rootViewController = SplashSceneView(nibName: "SplashSceneView", bundle: nil)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        self.window?.rootViewController = navigationController
        return true
    }
}

