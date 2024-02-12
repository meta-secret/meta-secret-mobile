//
//  MetaSecretCoreWrapper.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 19.10.2022.
//

import Foundation

protocol RustProtocol {
    func generate(for name: String) -> UserSecurityBox?
    func split(secret: String) -> [UserShareDto]
    func encrypt(share: ShareToEncrypt) -> AeadCipherText?
    func decrypt(model: DecryptModel) -> String?
    func generateMetaPassId(descriptionName: String) -> MetaPasswordId?
    func restoreSecret(model: RestoreModel) -> String?
}

//MARK: - Send to Rust Lib
final class RustTransporterManager: NSObject, RustProtocol {
    let dbManager: DBManagerProtocol
    let jsonSerializeManager: JsonSerealizable
    
    init(dbManager: DBManagerProtocol,
         jsonSerializeManager: JsonSerealizable) {
        self.dbManager = dbManager
        self.jsonSerializeManager = jsonSerializeManager
    }

    func generate(for name: String) -> UserSecurityBox? {
        let jsonData = jsonSerializeManager.jsonU8Generation(string: name)
        let count = jsonData.count
        guard let libResult = generate_signed_user(jsonData, count) else { return nil}
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        let userBox: UserSecurityBox? = try? jsonSerializeManager.objectGeneration(from: jsonString)
        return userBox
    }
    
    func split(secret: String) -> [UserShareDto] {
        var components = [UserShareDto]()

        let jsonData = jsonSerializeManager.jsonU8Generation(string: secret)
        guard let libResult = split_secret(jsonData, jsonData.count) else { return [] }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        components = (try? jsonSerializeManager.arrayGeneration(from: jsonString)) ?? [UserShareDto]()
        return components
    }

    func encrypt(share: ShareToEncrypt) -> AeadCipherText? {
        guard let jsonData = jsonSerializeManager.jsonU8Generation(from: share) else { return nil }
        guard let libResult = encrypt_secret(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let encryptedShare: AeadCipherText? = try? jsonSerializeManager.objectGeneration(from: jsonString)
        return encryptedShare
    }
    
    func decrypt(model: DecryptModel) -> String? {
        guard let jsonData = jsonSerializeManager.jsonU8Generation(from: model) else { return nil }
        guard let libResult = decrypt_secret(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        return jsonString
    }
    
    func generateMetaPassId(descriptionName: String) -> MetaPasswordId? {
        if let metaPassId = dbManager.readPassBy(descriptionName: descriptionName) {
            let encryptedShare: MetaPasswordId? = try? jsonSerializeManager.objectGeneration(from: metaPassId.metaPassId)
            return encryptedShare
        }
        
        let jsonData = jsonSerializeManager.jsonU8Generation(string: descriptionName)
        guard let libResult = generate_meta_password_id(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let metaPassId = MetaPassId()
        metaPassId.secretName = descriptionName
        metaPassId.metaPassId = jsonString
        dbManager.savePass(metaPassId)
        
        let encryptedShare: MetaPasswordId? = try? jsonSerializeManager.objectGeneration(from: jsonString)
        return encryptedShare
    }
    
    func restoreSecret(model: RestoreModel) -> String? {
        guard let jsonData = jsonSerializeManager.jsonU8Generation(from: model) else { return nil }
        guard let libResult = restore_secret(jsonData, jsonData.count) else { return nil }
        let jsonString = String(cString: libResult)
        rust_string_free(libResult)
        
        let encryptedShare: PlainText? = try? jsonSerializeManager.objectGeneration(from: jsonString)
        return encryptedShare?.text
    }
}
