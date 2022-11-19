//
//  DBManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.09.2022.
//

import Foundation
import RealmSwift

final class DBManager: Alertable {
    static let shared = DBManager()
    
    func saveSecret(_ secret: Secret) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(secret, update: .all)
            }
        } catch {
            showCommonError(error.localizedDescription.description)
        }
    }
    
    func readSecretBy(description: String) -> Secret? {
        do {
            let realm = try Realm()
            let specificSecret = realm.object(ofType: Secret.self, forPrimaryKey: description)
            return specificSecret
        } catch {
            showCommonError(error.localizedDescription.description)
        }
        return nil
    }
    
    func getAllSecrets() -> [Secret] {
        do {
            let realm = try Realm()
            let objs = realm.objects(Secret.self)
            return Array(objs)
        } catch {
            showCommonError(error.localizedDescription.description)
        }
        return []
    }
}
