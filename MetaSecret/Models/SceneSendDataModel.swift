//
//  SceneSendDataModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.09.2022.
//

import Foundation

struct SceneSendDataModel {
    let vault: Vault?
    let callBack: ((Bool?)->())?
    let mainStringValue: String?
    let stringValue: String?
    let modeType: ModeType?
    
    init(vault: Vault? = nil, mainStringValue: String? = nil, stringValue: String? = nil, modeType: ModeType? = nil, callBack: ((Bool?)->())? = nil) {
        self.vault = vault
        self.callBack = callBack
        self.mainStringValue = mainStringValue
        self.stringValue = stringValue
        self.modeType = modeType
    }
}
