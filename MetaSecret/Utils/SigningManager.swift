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
    func generateKeys(for userName: String) -> UserSignature?
//    func decryptData(_ secret: String, key: String, name: String)
}

extension Signable {
    func generateKeys(for userName: String) -> UserSignature? {
        let user = RustTransporterManager().generate(for: userName)
        return user
    }
}
