//
//  SigningManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation
import CryptoKit

protocol Signable {
    func generateKeys(for userName: String) -> User
    func signData(_ data: Data, for user: User?)
    func checkSign(_ dataToSign: Data)
}

extension Signable {
    func generateKeys(for userName: String) -> User {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        
        let privateKeyData = privateKey.rawRepresentation
        let publicKeyData = publicKey.rawRepresentation
        
        let user = User(userName: userName, publicKey: publicKeyData, privateKey: privateKeyData)
        return user
    }
    
    func signData(_ data: Data, for user: User? = nil) {
        
    }
    
    func checkSign(_ dataToSign: Data) {
        
        //        let initializedSigningPublicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: publicKeyData)
        //        if initializedSigningPublicKey.isValidSignature(signature, for: dataToSign) {
        //            print("The signature is valid.")
        //        }
    }
}
