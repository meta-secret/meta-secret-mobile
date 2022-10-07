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
    func encryptData(_ data: Data, key: Data, name: String) -> Data?
    func decryptData(_ encryptedData: Data, key: Data, name: String) -> String?
}

extension Signable {
    func generateKeys(for userName: String) -> User? {
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
        
        let user = User(userName: userName, deviceName: UIDevice.current.name, deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "", publicKey: publicKeyData, privateKey: privateKeyData, publicRSAKey: publicRSAKeyData, privateRSAKey: privateRSAKeyData)

        return user
    }
    
    func signData(_ data: Data, for user: User) {
        guard let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: user.privateKey) else { return }
        guard let signature = try? privateKey.signature(for: data) else { return }
        user.addSignature(signature)
    }
    
    func check(_ signature: Data) -> Bool {
        guard let user = mainUser else {
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
        
        guard let privateKey = SecKeyCreateRandomKey(attributes(tag: userName), nil) else {
            showCommonError(nil)
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            showCommonError(nil)
            return nil
        }
        
        return (privateKey, publicKey)
    }
    
    func encryptData(_ data: Data, key: Data, name: String) -> Data? {
        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(key as CFData, attributes(tag: name), &error) else {
            showCommonError(error.debugDescription)
            return nil
        }
       
        guard let encryptedData = SecKeyCreateEncryptedData(secKey, algorithm(), data as CFData, nil) else {
            showCommonError(nil)
            return nil
        }
        
        return encryptedData as Data
    }
    
    func decryptData(_ encryptedData: Data, key: Data, name: String) -> String? {
        var error: Unmanaged<CFError>? = nil
        
        guard let secKey = SecKeyCreateWithData(key as CFData, attributes(tag: name, isPrivate: true), &error) else {
            showCommonError(error.debugDescription)
            return nil
        }
        
        guard let decryptedData = SecKeyCreateDecryptedData(secKey, algorithm(), encryptedData as CFData, &error) as Data? else {
            showCommonError(error.debugDescription)
            return nil
        }
        
        return (String(data: decryptedData, encoding: .utf8))
    }
    
    private func algorithm() -> SecKeyAlgorithm {
        return SecKeyAlgorithm.rsaEncryptionOAEPSHA384AESGCM
    }
    
    private func attributes(tag: String, isPrivate: Bool = false) -> CFDictionary {
        let keyClass = isPrivate ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String          : keyClass,
            kSecAttrKeySizeInBits as String     : 2048,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag.data(using: .utf8) ?? Data()
            ]
        ]
        
        return attributes as CFDictionary
    }
}
