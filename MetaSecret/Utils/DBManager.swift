//
//  DBManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.09.2022.
//

import Foundation
import RealmSwift

class DBManager: Alertable {
    static let shared = DBManager()
    
    func saveSecret(_ secret: Secret) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(secret)
            }
        } catch {
            showCommonError(error.localizedDescription.description)
        }
    }
}