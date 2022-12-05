//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class GetVault: HTTPRequest, UD {
    typealias ResponseType = GetVaultResult
    var params: String = "{}"
    var path: String = "getVault"
    
    init() {
        guard let userSignature else { return }
        self.params = userSignature.toJson()
    }
}

struct GetVaultResult: Codable {
    var msgType: String
    var data: GetVaultData?
    var error: String?
}

struct GetVaultData: Codable {
    var vaultInfo: VaultInfoStatus = .unknown
    var vault: VaultDoc?
}

enum VaultInfoStatus: String, Codable {
    case member
    case pending
    case declined
    case virtual
    case unknown
    
    func title() -> String {
        switch self {
        case .member:
            return Constants.Devices.member
        case .pending:
            return Constants.Devices.pending
        case .declined:
            return Constants.Devices.declined
        default:
            return ""
        }
    }
}
