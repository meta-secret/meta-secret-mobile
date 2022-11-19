//
//  SigningManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation
import UIKit
import CryptoKit
import Security

protocol Signable: Alertable, UD {
    func generateKeys(for userName: String) -> UserSecurityBox?
}

extension Signable {
    func generateKeys(for userName: String) -> UserSecurityBox? {
        let user = RustTransporterManager().generate(for: userName)
        return user
    }
}
