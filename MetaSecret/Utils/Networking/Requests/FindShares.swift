//
//  FindShares.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class FindShares: HTTPRequest, UD {
    typealias ResponseType = [SecretDistributionDoc]
    var params: [String : Any]?
    var path: String = "findShares"
    
    init() {
        guard let mainVault else { return }
        
        self.params = mainVault.createRequestJSon()
    }
}

struct SecretDistributionDoc: Codable {
    var distributionType: SecretDistributionType?
    var metaPassword: MetaPasswordRequest?
    var secretMessage: EncryptedMessage?
}
