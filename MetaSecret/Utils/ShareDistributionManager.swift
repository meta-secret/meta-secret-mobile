//
//  ShareDistributionManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation
#warning("UNIVERSAL MECHANISM NEEDED")
protocol ShareDistributionable {
    func distributeShares(_ shares: [PasswordShare], _ vaults: [Vault], description: String, callBack: ((Bool)->())?)
    func restorePassword(_ shares: [PasswordShare], _ vaults: [Vault], description: String, callBack: ((String)->())?)
}

class ShareDistributionManager: ShareDistributionable, UD, Alertable, JsonSerealizable {
    fileprivate enum SplittedType: Int {
        case fullySplitted = 3
        case allInOne = 1
        case partially = 2
    }
    
    fileprivate var shares: [PasswordShare] = [PasswordShare]()
    fileprivate var vaults: [Vault] = [Vault]()
    fileprivate var description: String = ""
    fileprivate var callBack: ((Bool)->())?
    
    func distributeShares(_ shares: [PasswordShare], _ vaults: [Vault], description: String, callBack: ((Bool)->())?) {
        guard let typeOfSharing = SplittedType(rawValue: vaults.count) else {
            callBack?(false)
            return
        }
        
        self.callBack = callBack
        self.vaults = vaults
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
    
    func restorePassword(_ shares: [PasswordShare], _ vaults: [Vault], description: String, callBack: ((String) -> ())?) {
//        Distribute(encodedShare: shares, reciverVault: vaults, description: description, type: .Recover).execute() { restoredPassword in
//            callBack?(restoredPassword)
//        }
    }
}

private extension ShareDistributionManager {
    //MARK: - DISTRIBUTIONS FLOWS
    func simpleDistribution(callBack: ((Bool)->())?) {
        let myGroup = DispatchGroup()
        var results = [Bool]()
        
        for i in 0..<shares.count {
            myGroup.enter()
            
            let vault: Vault
            let shareToEncrypt = shares[i]
            if vaults.count - 1 >= i {
                vault = vaults[i]
            } else {
                vault = vaults[0]
            }
            
            if let encryptedShare = encryptShare(shareToEncrypt, vault) {
                distribute([encryptedShare], vault: vault) { isSuccess in
                    results.append(isSuccess)
                    myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            let isFalse = results.first(where: {$0 == false}) ?? false
            callBack?(!isFalse)
        }
    }
    
    func partiallyDistribute(callBack: ((Bool)->())?) {
        #warning("FIX THIS PARTICULAR CASE TO COMMON")
        shares.append(shares[Constants.Common.neededMembersCount - 1])
        vaults.append(vaults[0])
        vaults.append(vaults[Constants.Common.neededMembersCount - 1])
        
        simpleDistribution(callBack: callBack)
    }
    
    //MARK: - ENCODING
    func encryptShare(_ share: PasswordShare, _ vault: Vault) -> AeadCipherText? {
        guard let keyManager = mainUser?.keyManager, let transportPublicKey = vault.transportPublicKey else {
            showCommonError(Constants.Errors.noMainUserError)
            return nil
        }
        
        let shareToEncode = ShareToEncrypt(senderKeyManager: keyManager, receiverPubKey: transportPublicKey, secret: jsonGeneration(from: share) ?? "")
        
        guard let encryptedShare = RustTransporterManager().encrypt(share: shareToEncode) else {
            showCommonError(Constants.Errors.encodeError)
            return nil
        }
        
        return encryptedShare
    }
    
    //MARK: - Distributing
    func distribute(_ shares: [AeadCipherText], vault: Vault, callBack: ((Bool)->())?) {
        for share in shares {
            guard let shareJson = jsonGeneration(from: share) else {
                showCommonError(Constants.Errors.objectToJsonError)
                return
            }
            
            Distribute(encodedShare: shareJson, reciverVault: vault, description: description, type: .Split).execute() { [weak self] result in
                print("WHAT NEXT??")
            }
        }
        callBack?(true)
    }
}
