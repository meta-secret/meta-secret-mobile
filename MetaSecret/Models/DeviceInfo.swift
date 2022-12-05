//
//  DeviceInfo.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 02.12.2022.
//

import UIKit

struct Device: Codable {
    var deviceName = UIDevice.current.name
    var deviceId = UIDevice.current.identifierForVendor?.uuidString
}
