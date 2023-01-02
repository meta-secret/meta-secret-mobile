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

protocol Signable {
    func generateKeys(for userName: String) -> UserSecurityBox?
}

class SigningManager: NSObject, Signable {
    private var rustManager: RustProtocol
    
    init(rustManager: RustProtocol) {
        self.rustManager = rustManager
    }
    
    func generateKeys(for userName: String) -> UserSecurityBox? {
        let user = rustManager.generate(for: userName)
        return user
    }
}
