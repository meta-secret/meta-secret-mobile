//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class GetVault: HTTPRequest {
    typealias ResponseType = Vault
    var params: [String : Any]?
    var path: String = "getVault"
    
    init(signature: String) {
        self.params = [
            "signature": signature
        ]
    }
}
