//
//  AlertModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let okButton: String?
    let cancelButton: String?
    let tintColor: UIColor?
    let okHandler: (()->())?
    let cancelHandler: (()->())?
    
    init(title: String, message: String, tintColor: UIColor? = .black, okButton: String? = Constants.Alert.ok, cancelButton: String? = Constants.Alert.cancel, okHandler: (()->())? = nil, cancelHandler: (()->())? = nil) {
        self.title = title
        self.message = message
        self.okButton = okButton
        self.cancelButton = cancelButton
        self.tintColor = tintColor
        self.okHandler = okHandler
        self.cancelHandler = cancelHandler
    }
}
