//
//  ShareDistributionManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation
import RealmSwift

#warning("UNIVERSAL MECHANISM NEEDED")
protocol ShareDistributionable {
    func distributeShares(_ shares: [PasswordShare], _ vaults: [UserSignature], description: String, callBack: ((Bool)->())?)
    func restorePassword(_ shares: [PasswordShare], _ vaults: [UserSignature], description: String, callBack: ((String)->())?)
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?, callBack: ((Bool)->())?)
}

class ShareDistributionManager: ShareDistributionable, UD, Alertable, JsonSerealizable {
    fileprivate enum SplittedType: Int {
        case fullySplitted = 3
        case allInOne = 1
        case partially = 2
    }
    
    fileprivate var shares: [PasswordShare] = [PasswordShare]()
    fileprivate var signatures: [UserSignature] = [UserSignature]()
    fileprivate var description: String = ""
    fileprivate var callBack: ((Bool)->())?
    
    func distributeShares(_ shares: [PasswordShare], _ signatures: [UserSignature], description: String, callBack: ((Bool)->())?) {
        guard let typeOfSharing = SplittedType(rawValue: signatures.count) else {
            callBack?(false)
            return
        }
        
        self.callBack = callBack
        self.signatures = signatures
        self.shares = shares
        self.description = description
        
        switch typeOfSharing {
        case .fullySplitted:
            simpleDistribution(callBack: callBack)
        case .allInOne:
            simpleDistribution(callBack: callBack)
        case .partially:
            break
        }
    }
    
    func restorePassword(_ shares: [PasswordShare], _ vaults: [UserSignature], description: String, callBack: ((String) -> ())?) {
//        Distribute(encodedShare: shares, reciverVault: vaults, description: description, type: .Recover).execute() { restoredPassword in
//            callBack?(restoredPassword)
//        }
    }
    
    func distribtuteToDB(_ shares: [SecretDistributionDoc]?, callBack: ((Bool)->())?) {
        for share in shares ?? [] {
            guard let description = share.metaPassword?.metaPassword.id.name else { break }
            
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
            if signatures.count - 1 >= i {
                signature = signatures[i]
            } else {
                signature = signatures[0]
            }
            
            if let encryptedShare = encryptShare(shareToEncrypt, signature.publicKey) {
                distribute([encryptedShare], receiver: signature) { isSuccess in
                    results.append(isSuccess)
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
    func encryptShare(_ share: PasswordShare, _ receiverPubKey: Base64EncodedText) -> AeadCipherText? {
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
    
    //MARK: - Distributing
    func distribute(_ shares: [AeadCipherText], receiver: UserSignature, callBack: ((Bool)->())?) {
        for share in shares {
            Distribute(encodedShare: share, receiver: receiver, description: description, type: .split).execute() { result in
                switch result {
                case .failure(_):
                    callBack?(false)
                default:
                    callBack?(true)
                }
            }
        }
    }
}
