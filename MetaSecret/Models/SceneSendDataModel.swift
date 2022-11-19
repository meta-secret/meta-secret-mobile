//
//  SceneSendDataModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.09.2022.
//

import Foundation

struct SceneSendDataModel {
    let vault: Vault?
    #warning("need <Result, Error>")
    let callBack: ((Bool)->())?
    let callBackVaults: (([Vault])->())?
    let mainStringValue: String?
    let stringValue: String?
    let modeType: ModeType?
    let stringArray: [String]?
    let shares: [PasswordShare]?
    let vaults: [Vault]?
    
    init(vault: Vault? = nil, mainStringValue: String? = nil, stringValue: String? = nil, modeType: ModeType? = nil, stringArray: [String]? = nil, shares: [PasswordShare]? = nil, vaults: [Vault]? = nil, callBack: ((Bool)->())? = nil, callBackVaults: (([Vault])->())? = nil) {
        self.vault = vault
        self.callBack = callBack
        self.mainStringValue = mainStringValue
        self.stringValue = stringValue
        self.modeType = modeType
        self.stringArray = stringArray
        self.shares = shares
        self.vaults = vaults
        self.callBackVaults = callBackVaults
    }
}
