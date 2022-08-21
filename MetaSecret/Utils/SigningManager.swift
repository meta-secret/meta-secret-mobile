//
//  SigningManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 20.08.2022.
//

import Foundation
import CryptoKit
import Security

protocol Signable: Alertable {
    func generateKeys(for userName: String) -> User?
    func signData(_ data: Data, for user: User?)
    func checkSign(_ dataToSign: Data)
    func encryptData(_ data: Data)
    func checkEncryptedData()
}

extension Signable {
    func generateKeys(for userName: String) -> User? {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        
        let privateKeyData = privateKey.rawRepresentation
        let publicKeyData = publicKey.rawRepresentation
        
        
        guard let keyPairRSA = getRSAKeyPairs(for: userName) else {
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
        
        let user = User(userName: userName, publicKey: publicKeyData, privateKey: privateKeyData, publicRSAKey: publicRSAKeyData, privateRSAKey: privateRSAKeyData)
        return user
    }
    
    func signData(_ data: Data, for user: User? = nil) {
        guard let privateKeyData = user?.privateKey else { return }
        guard let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData) else { return }
        guard let signature = try? privateKey.signature(for: data) else { return }
        user?.addSignature(signature)
    }
    
    func checkSign(_ dataToSign: Data) {
        
        //        let initializedSigningPublicKey = try! Curve25519.Signing.PublicKey(rawRepresentation: publicKeyData)
        //        if initializedSigningPublicKey.isValidSignature(signature, for: dataToSign) {
        //            print("The signature is valid.")
        //        }
    }
    
    //MARK: - RSA
    func getRSAKeyPairs(for userName: String) -> (privateRSAKey: SecKey, publicRSAkey: SecKey)? {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String     : 4096,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : userName,
                kSecAttrAccessControl as String     : access
            ]
        ]
                
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            showCommonError(error.debugDescription)
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            showCommonError(nil)
            return nil
        }
        
        return (privateKey, publicKey)
    }
    
    func encryptData(_ data: Data, for user: User? = nil) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String     : 4096,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : user?.userName ?? "",
                kSecAttrAccessControl as String     : access
            ]
        ]
        
        guard let privateKeyRSAData = user?.privateRSAKey else { return }
        guard let privateKeyRSA = SecKeyCreateWithData(privateKeyRSAData as CFData, attributes as CFDictionary, nil) else {
            showCommonError(nil)
            return
        }
       
        guard let signatureRSA = SecKeyCreateEncryptedData(privateKeyRSA, .ecdhKeyExchangeCofactorX963SHA1, data as CFData, nil) else {
            showCommonError(nil)
            return
        }
        user?.addRSASignature(signatureRSA as Data)
    }
    
    func checkEncryptedData() {
        
    }
}
