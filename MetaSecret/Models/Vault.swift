//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class Vault: Codable {
    var vaultName: String?
    var device: Device?
    var publicKey: String?
    var rsaPublicKey: String?
    var signature: String?
    var declinedJoins: [Vault]?
    var pendingJoins: [Vault]?
    var signatures: [Vault]?
}

struct Device: Codable {
    var deviceName: String?
    var deviceId: String?
}
