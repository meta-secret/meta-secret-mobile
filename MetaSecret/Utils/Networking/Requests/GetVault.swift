//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

final class GetVault: HTTPRequest {
    var params: String
    var path: String { return "getVault" }
    
    init(_ params: String) {
        self.params = params
    }
}

struct GetVaultResult: Codable {
    var msgType: String
    var data: GetVaultData?
    var error: String?
}

struct GetVaultData: Codable {
    var vaultInfo: VaultInfoStatus = .Unknown
    var vault: VaultDoc?
}

enum VaultInfoStatus: String, Codable {
    case Member
    case Pending
    case Declined
    case NotFound
    case Unknown
    
    func title() -> String {
        switch self {
        case .Member:
            return Constants.Devices.member
        case .Pending:
            return Constants.Devices.pending
        case .Declined:
            return Constants.Devices.declined
        default:
            return ""
        }
    }
}
