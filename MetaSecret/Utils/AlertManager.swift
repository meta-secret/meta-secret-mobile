//
//  AlertManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

protocol Alertable: Loaderable {
    func showCommonError(_ message: String?)
    func showCommonAlert(_ model: AlertModel)
}

extension Alertable {
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
        findRoot()?.present(alert, animated: true, completion: nil)
    }
}

