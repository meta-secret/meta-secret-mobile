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
    
    init(vault: Vault? = nil, callBack: (()->())? = nil) {
        self.vault = vault
        self.callBack = callBack
    }
}
