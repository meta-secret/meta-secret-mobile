//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class Vault: Codable {
    var vaultName: String?
    var deviceName: String?
    var publicKey: String?
    var rsaPublicKey: String?
    var signature: String?
    var pendingJoins: [Vault] = []
    var signatures: [Vault] = []
}
