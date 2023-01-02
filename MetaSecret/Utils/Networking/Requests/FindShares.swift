//
//  FindShares.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class FindShares: HTTPRequest {
    override init() {
        super.init()
        path = "findShares"
        guard let userSignature = userService.userSignature else { return }
        self.params = jsonService.jsonStringGeneration(from: userSignature) ?? "{}"
    }
}

//struct FindSharesResponse: Codable {
//    var msgType: String
//    var data: [SecretDistributionDoc]?
//    var error: String?
//}

struct SecretDistributionDoc: Codable {
    var distributionType: SecretDistributionType?
    var metaPassword: MetaPasswordRequest?
    var secretMessage: EncryptedMessage?
}
