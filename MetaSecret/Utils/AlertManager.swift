//
//  AlertManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit


final class AlertManager {
    static let shared = AlertManager()
    
    func showCommonError(_ presenter: UIViewController, message: String?) {
        let errorModel = AlertModel(presenter: presenter, title: Constants.Errors.error, message: message ?? Constants.Errors.swwError)
        showAlert(errorModel)
    }
    
    func showAlert(_ model: AlertModel) {
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
        
        model.presenter.present(alertController, animated: true)
    }
}
