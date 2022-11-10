//
//  Secret.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import Foundation
import RealmSwift

class Secret: Object {

    @objc dynamic var secretID = ""
    @objc dynamic var secretPart: String = ""

    override static func primaryKey() -> String? {
        return "secretID"
    }
}
