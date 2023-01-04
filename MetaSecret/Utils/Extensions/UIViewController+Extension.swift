//
//  UIViewController+Extension.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import UIKit
import SafariServices

/*
extension UIViewController {
    func modal(
        _ viewController: UIViewController?,
        includeIntoNavigationController: Bool = true,
        animated: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle? = nil,
        modalTransitionStyle: UIModalTransitionStyle? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let viewController = viewController else { return }
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder),
                        to: nil, from: nil, for: nil)
        
        if includeIntoNavigationController,
           let viewController = UINavigationController.rootViewController(viewController) {
            if let modalTransitionStyle = modalTransitionStyle {
                viewController.modalTransitionStyle = modalTransitionStyle
            }
            if let modalPresentationStyle = modalPresentationStyle {
                viewController.modalPresentationStyle = modalPresentationStyle
            }
            present(viewController, animated: animated, completion: completion)
        }
        else {
            present(viewController, animated: animated, completion: completion)
        }
    }
    
    func push(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController = viewController else { return }
        let navigationController = self.navigationController ?? (self as? UINavigationController)
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func sheet(title: String? = nil, actions: [UIAlertAction], message: String? = nil, preferredStyle: UIAlertController.Style = .actionSheet, addCancel: Bool = true, cancel: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        if addCancel {
            alertController.addAction(title: "Отмена".localized(),
                                      style: .cancel,
                                      isEnabled: true,
                                      handler: cancel)
        }
        
        modal(alertController, includeIntoNavigationController: false, animated: true)
    }
    
    var isAlert: Bool {
        return self.isMember(of: UIAlertController.self)
    }
    
    func dismissIfAlert() {
        if isAlert {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func show(url: String) {
        guard let url = URL(string: url) else { return }
        let browser = SFSafariViewController(url: url)
        browser.configuration.barCollapsingEnabled = false
        browser.configuration.entersReaderIfAvailable = false
        browser.dismissButtonStyle = .close
        browser.preferredBarTintColor = Assets.Colors.black2.color
        browser.modalPresentationStyle = .popover
        modal(browser)
    }
    
    func open(url: String) {
        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        open(url: URL(string: urlString))
    }
    
    func open(url: URL?) {
        guard var url = url else { return }
        let urlString = url.absoluteString
        let urlHasHttpPrefix = urlString.hasPrefix("http://")
        let urlHasHttpsPrefix = urlString.hasPrefix("https://")
        let validUrlString = (urlHasHttpPrefix || urlHasHttpsPrefix) ? urlString : "http://\(urlString)"
        
        guard let url = URL(string: validUrlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension UIViewController {
    func slideUp(_ viewController: UIViewController?, toBottomOf anchorView: UIView, shouldDim: Bool = true) {
        slideUp(viewController,
                verticalOffsetRatio: anchorView.bottomLineScreenSplitRatio,
                shouldDim: shouldDim)
    }
    
    func slideUp(
        _ viewController: UIViewController?,
        verticalOffsetRatio: CGFloat? = nil,
        shouldDim: Bool = true,
        shouldShowCloseButton: Bool = false,
        radius: CGFloat = 8.0,
        hasBlur: Bool = false,
        hasTopHandle: Bool = true,
        includeIntoNavigationController: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle? = nil,
        modalTransitionStyle: UIModalTransitionStyle? = nil,
        backGroundColor: UIColor? = nil
    ) {
        guard let viewController = viewController else {
            return
        }
        let slideUpContainer = SlideUpContainerViewController()
        slideUpContainer.modalPresentationStyle = .custom
        slideUpContainer.transitioningDelegate = slideUpContainer
        
        slideUpContainer.backGroundColor = backGroundColor
        slideUpContainer.viewControllerToAdd = viewController
        slideUpContainer.shouldDim = shouldDim
        slideUpContainer.shouldShowCloseButton = shouldShowCloseButton
        slideUpContainer.radius = radius
        slideUpContainer.hasBlur = hasBlur
        slideUpContainer.hasTopHandle = hasTopHandle
        if let verticalOffsetRatio = verticalOffsetRatio {
            slideUpContainer.verticalOffsetRatio = verticalOffsetRatio
        }
        modal(slideUpContainer, includeIntoNavigationController: includeIntoNavigationController, modalPresentationStyle: modalPresentationStyle, modalTransitionStyle: modalTransitionStyle)
    }
}

extension UIViewController {
    var canPresentViewController: Bool {
        return self.presentedViewController == nil
    }
    
    var concreteViewController: UIViewController {
        if let navVC = self as? UINavigationController,
           let navRootVC = navVC.viewControllers.first {
            return navRootVC
        }
        return self
    }
    
    var topmostPresentedViewController: UIViewController {
        if let tabVC = self as? UITabBarController,
           let selectedVC = tabVC.selectedViewController {
            return selectedVC.topmostPresentedViewController
        } else if let navVC = self as? UINavigationController,
                  let selectedVC = navVC.viewControllers.last {
            return selectedVC.topmostPresentedViewController
        } else if let presentedVC = self.presentedViewController {
            return presentedVC.topmostPresentedViewController
        } else {
            return self
        }
    }
    
    var isCurrentTopmostPresentedViewController: Bool {
        return topmostPresentedViewController == self
    }
}

extension UIViewController {
    var isRoot: Bool {
        let isRoot = self == UIApplication.keyWindow?.rootViewController
        let isNavigationRoot = navigationController == UIApplication.keyWindow?.rootViewController && navigationController?.viewControllers.count == 1
        return isRoot || isNavigationRoot
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        let noLastOfSeveralPushedToNavigation = (navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers.last == self)
        
        return (presentingIsModal || presentingIsNavigation || presentingIsTabBar) && !noLastOfSeveralPushedToNavigation
    }
    
    func setupNavigationBarAppearance(shouldSetCloseButton: Bool = true, withShadow: Bool = true) {
        let attributes = [NSAttributedString.Key.font : FontFamily.Roboto.regular.font(size: 18),
                          NSAttributedString.Key.foregroundColor : Assets.Colors.white100.color]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Assets.Colors.white100.color
        navigationController?.navigationBar.shadowImage = UIImage()
        if withShadow {
            navigationController?.navigationBar.addShadow(ofColor: Assets.Colors.white12.color, radius: 0, offset: CGSize(width: 0, height: 1), opacity: 0.5)
        }
        else {
            navigationController?.navigationBar.addShadow(ofColor: Assets.Colors.white12.color, radius: 0, offset: CGSize(width: 0, height: 0), opacity: 0.5)
        }
        navigationController?.navigationBar.layoutIfNeeded()
        navigationController?.navigationBar.barTintColor = Assets.Colors.black2.color
        
        if shouldSetCloseButton && (isModal || isRoot) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: Assets.Images.Common.closeIcon.image, style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
        }
    }
    
    @objc func didTapCloseButton(sender: Any) {
        closeButtonHandler()
    }
    
    @objc func closeButtonHandler(completion: (() -> Void)? = nil) {
        if isRoot {
            //(self as? ApplicationRouterDependantProtocol)?.router.route()
        }
        else {
            (navigationController ?? self).dismiss(animated: true, completion: completion)
        }
    }
}
*/
extension UIViewController {
    func setAttributedTitle(_ title: String?) {
        typealias AttrKey = NSAttributedString.Key
        let label = UILabel()
        let attributedStringKeys = [AttrKey.foregroundColor : UIColor.black, AttrKey.font: UIFont.avenirMedium(size: 18)]
        label.attributedText = NSAttributedString(string: title?.capitalized ?? "",
                                                  attributes: attributedStringKeys)
        navigationItem.titleView = label
    }
    
    func clearBackButtonTitle() {
        navigationItem.backButtonTitle = ""
    }
    
    func push(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController = viewController else { return }
        let navigationController = self.navigationController ?? (self as? UINavigationController)
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popUp(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController else { return }
        viewController.modalPresentationStyle = .overFullScreen
        findRoot()?.present(viewController, animated: false, completion: nil)
    }
    
    func root(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController else { return }
        findRoot()?.navigationController?.setViewControllers([viewController], animated: true)
    }
}

extension UIViewController {
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
