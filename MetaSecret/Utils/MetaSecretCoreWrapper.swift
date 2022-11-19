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
        let jsonData = jsonU8Generation(from: name)
        
        let signedUserJson = generate_signed_user(jsonData, jsonData.count)
        guard let signedUserJsonString = signedUserJson.asString() else { return nil }

        let userBox: UserSecurityBox? = object(from: signedUserJsonString)
        return userBox
    }
    
    func split(secret: String) -> [PasswordShare] {
        var components = [PasswordShare]()

        let secretData = jsonU8Generation(from: secret)
        let jsonResult = split_secret(secretData, secretData.count)
        guard let jsonString = jsonResult.asString() else { return []}

        components = array(from: jsonString) ?? []
        return components
    }

    func encode(share: EncodeShare) -> String? {
        guard let jsonData = jsonU8Generation(from: share) else { return nil }
        let result = encode_secret(jsonData, jsonData.count).asString()
        return result
    }
}

//MARK: - String translator
extension RustByteSlice {
    func asUnsafeBufferPointer() -> UnsafeBufferPointer<UInt8> {
        return UnsafeBufferPointer(start: bytes, count: len)
    }

    func asString(encoding: UInt = NSUTF8StringEncoding) -> String? {
        return String(bytes: asUnsafeBufferPointer(), encoding: String.Encoding(rawValue: encoding))
    }
}
