//
//  Secret.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import Foundation
import RealmSwift

final class Secret: Object {

    @objc dynamic var secretName = ""
    var shares = List<String>()
    
    override static func primaryKey() -> String? {
        return "secretName"
    }
}
