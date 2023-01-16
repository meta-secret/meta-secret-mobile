//
//  AlertManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

protocol Alertable {
    func showCommonError(_ message: String?)
    func showCommonAlert(_ model: AlertModel)
    func showLoader()
    func hideLoader()
}

class AlertManager: NSObject, Alertable {
    private var rootSearchService: RootFindable
    
    init(rootSearchService: RootFindable) {
        self.rootSearchService = rootSearchService
    }
    
    func showLoader() {
        let window = rootSearchService.findWindow()
        
        let isAlreadyLoader = window?.subviews.contains(where: {$0.tag == Constants.ViewTags.loaderTag}) ?? false
        guard !isAlreadyLoader else { return }
        
        let bgView = UIView(frame: window?.frame ?? CGRect.zero)
        bgView.backgroundColor = AppColors.mainBlack40
        
        let loginSpinner = UIActivityIndicatorView(style: .medium)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        loginSpinner.center = bgView.center
        bgView.addSubview(loginSpinner)
        
        loginSpinner.startAnimating()
        
        bgView.tag = Constants.ViewTags.loaderTag
        window?.addSubview(bgView)
    }
    
    func hideLoader() {
        let window = rootSearchService.findWindow()
        
        let loaderView = window?.subviews.first(where: {$0.tag == Constants.ViewTags.loaderTag})
        loaderView?.removeFromSuperview()
    }
    
    func showCommonError(_ message: String?) {
        let errorModel = AlertModel(title: Constants.Errors.error, message: message ?? Constants.Errors.swwError)
        showCommonAlert(errorModel)
    }
    
    func showCommonAlert(_ model: AlertModel) {
        let alertController = UIAlertController(title: model.title,
                                                message: model.message,
                                                preferredStyle: .alert)
        alertController.view.tintColor = model.tintColor
        alertController.addAction(.init(title: model.okButton,
                                        style: .default,
                                        handler: { _ in
            model.okHandler?()
        }))
        
        if let cancelButton = model.cancelButton {
            alertController.addAction(.init(title: cancelButton, style: .cancel, handler: { _ in
                model.cancelHandler?()
            }))
        }
        
        hideLoader()
        presentAlert(alertController)
    }
    
    private func presentAlert(_ alert: UIAlertController) {
//        closeAlert()
        rootSearchService.findRoot()?.present(alert, animated: true, completion: nil)
    }
    
    private func closeAlert() {
        let topController = rootSearchService.findTop()
        (topController as? UIAlertController)?.dismiss(animated: true)
    }
}
