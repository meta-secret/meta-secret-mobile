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
    func generateKeys(for userName: String) -> User?
    func signData(_ data: Data, for user: User)
    func check(_ signature: Data) -> Bool
    func encryptData(_ data: Data)
    func checkEncryptedData()
}

extension Signable {
    func generateKeys(for userName: String) -> User? {
        showLoader()
        
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        
        let privateKeyData = privateKey.rawRepresentation
        let publicKeyData = publicKey.rawRepresentation
        
        guard let keyPairRSA = try? getRSAKeyPairs(for: userName) else {
            showCommonError(nil)
            return nil
        }
        
        guard let privateRSAKeyData = SecKeyCopyExternalRepresentation(keyPairRSA.privateRSAKey, nil) as? Data else {
            showCommonError(nil)
            return nil
        }
        
        guard let publicRSAKeyData = SecKeyCopyExternalRepresentation(keyPairRSA.publicRSAkey, nil) as? Data else {
            showCommonError(nil)
            return nil
        }
        
        let user = User(userName: userName, deviceName: UIDevice.current.name, publicKey: publicKeyData, privateKey: privateKeyData, publicRSAKey: publicRSAKeyData, privateRSAKey: privateRSAKeyData)
        saveCustom(object: user, key: UDKeys.localVault)
        
        hideLoader()
        return user
    }
    
    func signData(_ data: Data, for user: User) {
        guard let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: user.privateKey) else { return }
        guard let signature = try? privateKey.signature(for: data) else { return }
        user.addSignature(signature)
    }
    
    func check(_ signature: Data) -> Bool {
        guard let user = readCustom(object: User.self, key: UDKeys.localVault) else {
            showCommonError(nil)
            return false
        }
                
        let initializedSigningPublicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: user.publicKey)
        if initializedSigningPublicKey.isValidSignature(signature, for: user.userName.data(using: .utf8) ?? Data()) {
            return true
        }
        return false
    }
    
    //MARK: - RSA
    private func getRSAKeyPairs(for userName: String) throws -> (privateRSAKey: SecKey, publicRSAkey: SecKey)? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String     : 4096,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : userName.data(using: .utf8)!
            ]
        ]
        
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else {
            showCommonError(nil)
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            showCommonError(nil)
            return nil
        }
        
        return (privateKey, publicKey)
    }
    
    func encryptData(_ data: Data) {
        guard let user = readCustom(object: User.self, key: UDKeys.localVault) else {
            showCommonError(nil)
            return
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String     : 4096,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : user.userName.data(using: .utf8) ?? Data()
            ]
        ]
        
        guard let privateKeyRSA = SecKeyCreateWithData(user.privateRSAKey as CFData, attributes as CFDictionary, nil) else {
            showCommonError(nil)
            return
        }
       
        guard let signatureRSA = SecKeyCreateEncryptedData(privateKeyRSA, .ecdhKeyExchangeCofactorX963SHA1, data as CFData, nil) else {
            showCommonError(nil)
            return
        }
        user.addRSASignature(signatureRSA as Data)
    }
    
    func checkEncryptedData() {
        
    }
}
