//
//  SceneSendDataModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.09.2022.
//

import Foundation

struct SceneSendDataModel {
    let vault: Vault?
    let callBack: (()->())?
    let mainStringValue: String?
    let stringValue: String?
    
    init(vault: Vault? = nil, mainStringValue: String, stringValue: String, callBack: (()->())? = nil) {
        self.vault = vault
        self.callBack = callBack
        self.mainStringValue = mainStringValue
        self.stringValue = stringValue
    }
}
