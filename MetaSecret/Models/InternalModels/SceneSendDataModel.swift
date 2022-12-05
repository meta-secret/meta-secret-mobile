//
//  SceneSendDataModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.09.2022.
//

import Foundation

struct SceneSendDataModel {
    let vault: VaultDoc?
    let signature: UserSignature?
    #warning("need <Result, Error>")
    let callBack: ((Bool)->())?
    let callBackVaults: (([VaultDoc])->())?
    let mainStringValue: String?
    let stringValue: String?
    let modeType: ModeType?
    let stringArray: [String]?
    let shares: [PasswordShare]?
    let vaults: [VaultDoc]?
    let signatures: [UserSignature]?
    
    init(vault: VaultDoc? = nil, signature: UserSignature? = nil, mainStringValue: String? = nil, stringValue: String? = nil, modeType: ModeType? = nil, stringArray: [String]? = nil, shares: [PasswordShare]? = nil, vaults: [VaultDoc]? = nil, signatures: [UserSignature]? = nil, callBack: ((Bool)->())? = nil, callBackVaults: (([VaultDoc])->())? = nil, callBackSignatures: (([UserSignature])->())? = nil) {
        self.vault = vault
        self.callBack = callBack
        self.mainStringValue = mainStringValue
        self.stringValue = stringValue
        self.modeType = modeType
        self.stringArray = stringArray
        self.shares = shares
        self.vaults = vaults
        self.callBackVaults = callBackVaults
        self.signature = signature
        self.signatures = signatures
    }
}
