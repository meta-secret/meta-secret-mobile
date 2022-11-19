//
//  ShareDistributionManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 17.11.2022.
//

import Foundation

protocol ShareDistributionable {
    func distributeShares(_ shares: [PasswordShare], _ vaults: [Vault])
}

extension ShareDistributionable {
    func distributeShares(_ shares: [PasswordShare], _ vaults: [Vault]) {
        
    }
}

/*
 func encodeInternal(callBack: (()->())?) {
     guard let keyManager = mainUser?.keyManager, let activeVaults else {
         showCommonError(nil)
         callBack?()
         return
     }
     
     for index in 0..<activeVaults.count {
         let vault = activeVaults[index]
         let shareToEncode = EncodeShare(senderKeyManager: keyManager, receiversPubKeys: vault.transportPublicKey?.base64Text ?? "", secret: components[index].shareBlocks?.first?.data?.base64Text ?? "")
         guard let encodedShare = RustTransporterManager().encode(share: shareToEncode) else {
             showCommonError(nil)
             callBack?()
             return
         }
         
         if (vault.device?.deviceId == mainVault?.device?.deviceId || (vault.isVirtual ?? false)) {
             var description = ""
             if (vault.isVirtual ?? false) {
                 description = "\(self.description)*$*\(vault.vaultName)"
             } else {
                 description = self.description
             }

             saveToDB(share: encodedShare, description: description, isVirtual: (vault.isVirtual ?? false))
         } else {
             Distribute(encodedShare: encodedShare, reciverVault: vault, description: description, type: .Split).execute() { result in
                 print("")
             }
         }
     }
     
     callBack?()
 }
 */
