//
//  FindShares.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

class FindShares: HTTPRequest, UD {
    typealias ResponseType = SecretDistributionDoc
    var params: [String : Any]?
    var path: String = "findShares"
    
    init() {
        guard let mainVault else { return }
        
        self.params = mainVault.createRequestJSon()
    }
}

struct SecretDistributionDoc: Codable {
    var res: String
//    var distributionType: SecretDistributionType? = nil
//    var metaPassword: MetaPasswordRequest? = nil
//    var secretMessage: EncryptedMessage? = nil
}
