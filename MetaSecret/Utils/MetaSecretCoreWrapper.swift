//
//  MetaSecretCoreWrapper.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 19.10.2022.
//

import Foundation

//MARK: - Send to Rust Lib
final class RustTransporterManager: JsonSerealizable {
    func generate(for name: String) -> UserSecurityBox? {
        let jsonData = jsonU8Generation(string: name)
        guard let libResult = generate_signed_user(jsonData, jsonData.count) else { return nil}
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let userBox: UserSecurityBox? = objectGeneration(from: jsonString)
        return userBox
    }
    
    func split(secret: String) -> [PasswordShare] {
        var components = [PasswordShare]()

        let jsonData = jsonU8Generation(string: secret)
        guard let libResult = split_secret(jsonData, jsonData.count) else { return [] }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        components = arrayGeneration(from: jsonString) ?? []
        return components
    }

    func encrypt(share: ShareToEncrypt) -> AeadCipherText? {
        guard let jsonData = jsonU8Generation(from: share) else { return nil }
        guard let libResult = encrypt_secret(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let encryptedShare: AeadCipherText? = objectGeneration(from: jsonString)
        return encryptedShare
    }
    
    func generateMetaPassId(description: String) -> MetaPasswordId? {
        let jsonData = jsonU8Generation(string: description)
        guard let libResult = generate_meta_password_id(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let encryptedShare: MetaPasswordId? = objectGeneration(from: jsonString)
        return encryptedShare
    }
}
