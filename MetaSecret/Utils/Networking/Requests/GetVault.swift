//
//  GetVault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation

class GetVault: HTTPRequest, UD {
    typealias ResponseType = GetVaultResult
    var params: [String : Any]?
    var path: String = "getVault"
    
    init() {
        guard let user = mainUser else { return }
        
        self.params = [
            "vaultName": user.name(),
            "device": ["deviceName": user.deviceName, "deviceId": user.deviceId],
            "publicKey": user.publicKey(),
            "rsaPublicKey": user.transportPublicKey(),
            "signature": user.userSignature()
        ]
    }
}

struct GetVaultResult: Codable {
    var status: VaultInfoStatus = .unknown
    var vault: Vault?
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
