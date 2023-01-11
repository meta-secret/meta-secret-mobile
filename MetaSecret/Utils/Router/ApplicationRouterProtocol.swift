//
//  ApplicationRouterProtocol.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import Foundation

import UIKit
import Swinject
import PromiseKit

protocol ApplicationRouterProtocol : UIApplicationDelegate {
    var assembler: Assembler! { get set }
    
    func start(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func route()
    func resolve<T>(_ type: T.Type) -> T?
}

class ApplicationRouter : NSObject, ApplicationRouterProtocol {
    private let window: UIWindow
    private let usersService: UsersServiceProtocol
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    var assembler: Assembler!
    
    init(window: UIWindow,
         usersService: UsersServiceProtocol) {
        self.window = window
        self.usersService = usersService
    }
    
    func start(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        showSplash()
    }

    func route() {
        guard usersService.deviceStatus == .Member else {
            routeUnauthenticated()
            return
        }
            
        routeAuthenticated()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return assembler.resolver.resolve(type)
    }
}

// Routing
extension ApplicationRouter {
    private func routeAuthenticated() {
        showMain()
    }
    
    private func routeUnauthenticated() {
        if usersService.shouldShowOnboarding {
            showOnboarding()
        } else {
            showLogin()
        }
    }
}

// Navigation
extension ApplicationRouter {
    private func showSplash() {
        let splashViewController = resolve(SplashSceneView.self)
        show(splashViewController)
    }
    
    private func showOnboarding() {
        show(resolve(OnboardingSceneView.self))
    }
    
    private func showMain() {
        guard let mainViewController = resolve(MainSceneView.self) else { return }
        mainViewController.viewModel.delegate = mainViewController
        show(UINavigationController(rootViewController: mainViewController))
    }
    
    private func showLogin() {
        guard let loginViewController = resolve(LoginSceneView.self) else { return }
        loginViewController.viewModel.delegate = loginViewController
        show(loginViewController)
    }
        
    private func show(_ viewController: UIViewController?, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        guard let viewController = viewController else { return }
        switchRoot(to: viewController, animated: animated, completion)
    }
        
    private func switchRoot(to viewController: UIViewController, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        window.switchRootViewController(to: viewController, animated: animated, duration: 0.2, options: .transitionCrossDissolve, completion)
    }
}
