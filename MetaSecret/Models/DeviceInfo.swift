//
//  DeviceInfo.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.12.2022.
//

import UIKit

struct Device: Codable {
    var deviceName: String
    var deviceId: String?
    
    init() {
        self.deviceName = UIDevice.current.name
        self.deviceId = getUUID()
    }
    
    private func getUUID() -> String? {
        let keychain = KeyChainManager()
        let uuidKey = "com.metaSecret.unique_uuid"

        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey) {
            return uuid
        }

        guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }

        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
        return newId
    }
}
