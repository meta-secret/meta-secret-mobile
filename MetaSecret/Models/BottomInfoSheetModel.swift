//
//  BottomInfoSheetModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 10.09.2022.
//

import Foundation
import UIKit

struct BottomInfoSheetModel {
    let title: String
    let message: String
    let buttonHandler: (()->())?
    
    init(title: String, message: String, buttonHandler: (()->())? = nil) {
        self.title = title
        self.message = message
        self.buttonHandler = buttonHandler
    }
}
