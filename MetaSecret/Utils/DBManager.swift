//
//  DBManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.09.2022.
//

import Foundation
import RealmSwift

protocol DBManagerProtocol {
    func saveSecret(_ secret: Secret)
    func readSecretBy(description: String) -> Secret?
    func getAllSecrets() -> [Secret]
    func savePass(_ pass: MetaPassId)
    func readPassBy(description: String) -> MetaPassId?
}

final class DBManager: NSObject, DBManagerProtocol {
    override init() {}
    
    #warning("MAKE GENERIC METHODS")
    // MARK: - SECRET
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
    
    // MARK: - META PASS
    func savePass(_ pass: MetaPassId) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(pass, update: .all)
            }
        } catch {
            showCommonError(error.localizedDescription.description)
        }
    }
    
    func readPassBy(description: String) -> MetaPassId? {
        do {
            let realm = try Realm()
            let specificPass = realm.object(ofType: MetaPassId.self, forPrimaryKey: description)
            return specificPass
        } catch {
            showCommonError(error.localizedDescription.description)
        }
        return nil
    }
}
