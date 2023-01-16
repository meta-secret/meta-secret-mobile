//
//  RootControllerManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 21.08.2022.
//

import Foundation
import UIKit

protocol RootFindable {
    func findRoot() -> UIViewController?
    func findWindow() -> UIWindow?
    func findTop() -> UIViewController?
}

class RootControllerManager: NSObject, RootFindable {
    override init() {
    }
    
    func findRoot() -> UIViewController? {
        var rootViewController = findWindow()?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }

        return rootViewController
    }
    
    func findWindow() -> UIWindow? {
        let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.window
    }
    
    func findTop() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        return nil
    }
}
