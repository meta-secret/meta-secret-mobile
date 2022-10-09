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
    let stringArray: [String]?
    
    init(vault: Vault? = nil, mainStringValue: String? = nil, stringValue: String? = nil, modeType: ModeType? = nil, stringArray: [String]? = nil, callBack: ((Bool?)->())? = nil) {
        self.vault = vault
        self.callBack = callBack
        self.mainStringValue = mainStringValue
        self.stringValue = stringValue
        self.modeType = modeType
        self.stringArray = stringArray
    }
}
