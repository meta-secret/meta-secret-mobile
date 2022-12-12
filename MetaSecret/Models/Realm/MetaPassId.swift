//
//  MetaPassId.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 09.12.2022.
//

import Foundation
import RealmSwift

final class MetaPassId: Object {

    @objc dynamic var secretName: String = ""
    @objc dynamic var metaPassId: String = ""
    
    override static func primaryKey() -> String? {
        return "secretName"
    }
}
