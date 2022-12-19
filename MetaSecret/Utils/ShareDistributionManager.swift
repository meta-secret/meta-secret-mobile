//
//  ShareDistributionManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation
import RealmSwift

#warning("UNIVERSAL MECHANISM NEEDED")
protocol ShareDistributionProtocol {
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], description: String, callBack: ((Bool)->())?)
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?, callBack: ((Bool)->())?)
}

final class ShareDistributionManager: ShareDistributionProtocol, UD, Alertable, JsonSerealizable {
    fileprivate enum SplittedType: Int {
        case fullySplitted = 3
        case allInOne = 1
        case partially = 2
    }
    
    fileprivate var shares: [UserShareDto] = [UserShareDto]()
    fileprivate var signatures: [UserSignature] = [UserSignature]()
    fileprivate var description: String = ""
    fileprivate var callBack: ((Bool)->())?
    
    func distributeShares(_ shares: [UserShareDto], _ signatures: [UserSignature], description: String, callBack: ((Bool)->())?) {
        guard let typeOfSharing = SplittedType(rawValue: signatures.count) else {
            callBack?(false)
            return
        }
        
        self.callBack = callBack
        self.signatures = signatures
        self.shares = shares
        self.description = description
        
        switch typeOfSharing {
        case .fullySplitted, .allInOne:
            simpleDistribution(callBack: callBack)
        case .partially:
            partiallyDistribute(callBack: callBack)
        }
    }
    
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?, callBack: ((Bool)->())?) {
        for share in shares ?? [] {
            guard let description = share.metaPassword?.metaPassword.id.name,
                  share.distributionType == .split else { break }
            
            if let secret = DBManager.shared.readSecretBy(description: description) {
                if let shareJsonString = jsonStringGeneration(from: share) {
                    let updatesSecret = Secret()
                    updatesSecret.secretName = secret.secretName
                    let existedShares = List<String>()
                    
                    for secretShare in secret.shares {
                        existedShares.append(secretShare)
                    }
                    existedShares.append(shareJsonString)
                    updatesSecret.shares = existedShares
                    DBManager.shared.saveSecret(updatesSecret)
                }
            } else {
                let newSecret = Secret()
                newSecret.secretName = share.metaPassword?.metaPassword.id.name ?? ""
                newSecret.shares = List<String>()
                if let shareJsonString = jsonStringGeneration(from: share) {
                    newSecret.shares.append(shareJsonString)
                }
                DBManager.shared.saveSecret(newSecret)
            }
        }
        callBack?(!(shares ?? []).isEmpty)
    }
}

private extension ShareDistributionManager {
    //MARK: - DISTRIBUTIONS FLOWS
    func simpleDistribution(callBack: ((Bool)->())?) {
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
                DistributionConnectorManager.shared.distributeSharesToMembers([encryptedShare], receiver: signature, description: description) { isOk in
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
    
    func partiallyDistribute(callBack: ((Bool)->())?) {
        #warning("FIX THIS PARTICULAR CASE TO COMMON")
        shares.append(shares[Constants.Common.neededMembersCount - 1])
        signatures.append(signatures[0])
        signatures.append(signatures[Constants.Common.neededMembersCount - 1])
        
        simpleDistribution(callBack: callBack)
    }
    
    //MARK: - ENCODING
    func encryptShare(_ share: UserShareDto, _ receiverPubKey: Base64EncodedText) -> AeadCipherText? {
        guard let keyManager = securityBox?.keyManager else {
            showCommonError(Constants.Errors.noMainUserError)
            return nil
        }
        
        let shareToEncode = ShareToEncrypt(senderKeyManager: keyManager, receiverPubKey: receiverPubKey, secret: share.toJson())
        
        guard let encryptedShare = RustTransporterManager().encrypt(share: shareToEncode) else {
            showCommonError(Constants.Errors.encodeError)
            return nil
        }
        
        return encryptedShare
    }
}
