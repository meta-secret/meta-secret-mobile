//
//  RestoreModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.12.2022.
//

import Foundation

final class RestoreModel: BaseModel {
    var keyManager: SerializedKeyManager
    var docOne: SecretDistributionDoc
    var docTwo: SecretDistributionDoc
    
    init(keyManager: SerializedKeyManager, docOne: SecretDistributionDoc, docTwo: SecretDistributionDoc) {
        self.keyManager = keyManager
        self.docOne = docOne
        self.docTwo = docTwo
    }
}

final class DecryptModel: BaseModel {
    var keyManager: SerializedKeyManager
    var doc: SecretDistributionDoc
    
    init(keyManager: SerializedKeyManager, doc: SecretDistributionDoc) {
        self.keyManager = keyManager
        self.doc = doc
    }
}
