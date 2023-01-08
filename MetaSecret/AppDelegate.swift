//
//  AppDelegate.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 24.07.2022.
//

import UIKit
import Swinject
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let assembler = Assembler()
    var router: ApplicationRouterProtocol!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bootstrap(launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return router.application!(app, open: url, options: options)
    }
        
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return router.application!(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        router.applicationDidBecomeActive?(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        router.applicationDidEnterBackground?(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        router.applicationWillEnterForeground?(application)
    }
        
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return router.application!(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        router.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        router.application!(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}

extension AppDelegate {
    private func bootstrap(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        assembler.apply(assemblies: [ApplicationAssembly(),
                                     ManagersAssembly(),
                                     APIClientsAssembly()])
        window = assembler.resolver.resolve(UIWindow.self)
        router = assembler.resolver.resolve(ApplicationRouterProtocol.self)
        router.assembler = assembler
        router.start(launchOptions)
    }
}
