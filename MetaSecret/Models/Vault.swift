//
//  Vault.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import Foundation

final class Vault: Codable {
    var vaultName: String?
    var publicKey: String?
    var signature: String?
    var signatures: [Vault] = []
    var pendingJoins: [Vault] = []
}
