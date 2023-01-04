//
//  ShareDistributionManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation
import RealmSwift
import PromiseKit

#warning("UNIVERSAL MECHANISM NEEDED")
protocol ShareDistributionProtocol {
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], description: String) -> Promise<Void>
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?) -> Promise<Void>
}

final class ShareDistributionManager: NSObject, ShareDistributionProtocol {
    fileprivate enum SplittedType: Int {
        case fullySplitted = 3
        case allInOne = 1
        case partially = 2
    }
    
    fileprivate var shares: [UserShareDto] = [UserShareDto]()
    fileprivate var signatures: [UserSignature] = [UserSignature]()
    fileprivate var secretDescription: String = ""
    
    private var jsonSerializationManager: JsonSerealizable
    private var dbManager: DBManagerProtocol
    private var userService: UsersServiceProtocol
    private var alertManager: Alertable
    private var rustManager: RustProtocol
    private var distributionConnectorManager: DistributionConnectorManagerProtocol
    
    init(jsonSerializationManager: JsonSerealizable,
         dbManager: DBManagerProtocol,
         userService: UsersServiceProtocol,
         alertManager: Alertable,
         rustManager: RustProtocol,
         distributionConnectorManager: DistributionConnectorManagerProtocol) {
        self.jsonSerializationManager = jsonSerializationManager
        self.dbManager = dbManager
        self.userService = userService
        self.alertManager = alertManager
        self.rustManager = rustManager
        self.distributionConnectorManager = distributionConnectorManager
    }
    
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], description: String) -> Promise<Void> {
        guard let typeOfSharing = SplittedType(rawValue: signatures.count) else {
            return Promise(error: MetaSecretErrorType.distribute)
        }
        
        self.signatures = signatures
        self.shares = shares
        self.secretDescription = description
        
        switch typeOfSharing {
        case .fullySplitted, .allInOne:
            return simpleDistribution()
        case .partially:
            return partiallyDistribute()
        }
        return Promise().asVoid()
    }
    
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?) -> Promise<Void> {
        guard let shares else {
            return Promise(error: MetaSecretErrorType.distributionDBError)
        }
        let dictionary = shares.reduce(into: [String: [SecretDistributionDoc]]()) { result, object in
            let array = result[object.metaPassword?.metaPassword.id.name ?? "NoN"] ?? []
            result[object.metaPassword?.metaPassword.id.name ?? "NoN"] = array + [object]
        }

        for (description, shares) in dictionary {
            let filteredShares = shares.filter({$0.distributionType == .split})
                let newSecret = Secret()
                newSecret.secretName = description
                newSecret.shares = List<String>()
            let mappedShares = filteredShares.map {jsonSerializationManager.jsonStringGeneration(from: $0)}
                for item in mappedShares {
                    newSecret.shares.append(item ?? "")
                }
            dbManager.saveSecret(newSecret)
        }
        return Promise().asVoid()
    }
}

private extension ShareDistributionManager {
    //MARK: - DISTRIBUTIONS FLOWS
    func simpleDistribution() -> Promise<Void>{
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
        for i in 0..<shares.count {
            myGroup.enter()
            
            let signature: UserSignature
            let shareToEncrypt = shares[i]
            if signatures.count > i {
                signature = signatures[i]
            } else {
                signature = signatures[0]
            }
            
            if let encryptedShare = encryptShare(shareToEncrypt, signature.transportPublicKey) {
                distributionConnectorManager.distributeSharesToMember ([encryptedShare], receiver: signature, description: description) { isOk in
                    results.append(isOk)
                    myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            guard let _ = results.first(where: {$0 == false}) else {
                callBack?(true)
                return
            }
            callBack?(false)
        }
    }
    
    func partiallyDistribute() -> Promise<Void> {
        guard let lastShare = shares.last else { return Promise(error: MetaSecretErrorType.commonError) }
        shares.append(lastShare)
        signatures.append(contentsOf: signatures)
        
        return simpleDistribution()
    }
    
    //MARK: - ENCODING
    func encryptShare(_ share: UserShareDto, _ receiverPubKey: Base64EncodedText) -> AeadCipherText? {
        guard let keyManager = userService.securityBox?.keyManager else {
            alertManager.showCommonError(Constants.Errors.noMainUserError)
            return nil
        }
        
        let shareToEncode = ShareToEncrypt(senderKeyManager: keyManager, receiverPubKey: receiverPubKey, secret: jsonSerializationManager.jsonStringGeneration(from: share) ?? "")
        
        guard let encryptedShare = rustManager.encrypt(share: shareToEncode) else {
            alertManager.showCommonError(Constants.Errors.encodeError)
            return nil
        }
        
        return encryptedShare
    }
}
