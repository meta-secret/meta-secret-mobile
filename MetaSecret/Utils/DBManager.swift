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
    func readSecretBy(descriptionName: String) -> Secret?
    func getAllSecrets() -> [Secret]
    func savePass(_ pass: MetaPassId)
    func readPassBy(descriptionName: String) -> MetaPassId?
}

final class DBManager: NSObject, DBManagerProtocol {
    #warning("remove alertManager")
    private let alertManager: Alertable
    
    init(alertManager: Alertable) {
        self.alertManager = alertManager
    }
    
    #warning("MAKE GENERIC METHODS")
    // MARK: - SECRET
    func saveSecret(_ secret: Secret) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(secret, update: .all)
            }
        } catch {
            alertManager.showCommonError(error.localizedDescription.description)
        }
    }
    
    func readSecretBy(descriptionName: String) -> Secret? {
        do {
            let realm = try Realm()
            let specificSecret = realm.object(ofType: Secret.self, forPrimaryKey: descriptionName)
            return specificSecret
        } catch {
            alertManager.showCommonError(error.localizedDescription.description)
        }
        return nil
    }
    
    func getAllSecrets() -> [Secret] {
        do {
            let realm = try Realm()
            let objs = realm.objects(Secret.self)
            return Array(objs)
        } catch {
            alertManager.showCommonError(error.localizedDescription.description)
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
            alertManager.showCommonError(error.localizedDescription.description)
        }
    }
    
    func readPassBy(descriptionName: String) -> MetaPassId? {
        do {
            let realm = try Realm()
            let specificPass = realm.object(ofType: MetaPassId.self, forPrimaryKey: descriptionName)
            return specificPass
        } catch {
            alertManager.showCommonError(error.localizedDescription.description)
        }
        return nil
    }
}
