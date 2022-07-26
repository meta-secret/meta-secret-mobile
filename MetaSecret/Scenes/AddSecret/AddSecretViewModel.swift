//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import UIKit

protocol AddSecretProtocol {
    func close()
    func showRestoreResult(password: String?)
}

final class AddSecretViewModel: UD, Routerable, Signable, JsonSerealizable {
    //MARK: - PROPERTIES
    enum Config {
        static let minMembersCount = 3
    }
    
    private var delegate: AddSecretProtocol? = nil
    private var components: [UserShareDto] = [UserShareDto]()
    private var signatures: [UserSignature]? = nil
    private lazy var activeSignatures: [UserSignature] = [UserSignature]()
    private var description: String = ""
//    private var distributionService: DistributionConnectorManagerProtocol
    
    var isFullySplitted: Bool = false
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol/*, distributionService: DistributionConnectorManagerProtocol*/) {
        self.delegate = delegate
//        self.distributionService = distributionService
    }
    
    //MARK: - PUBLIC METHODS
    func getVault() {
        self.signatures?.removeAll()
        self.signatures = self.mainVault?.signatures
        if self.signatures?.count ?? 0 <= Constants.Common.neededMembersCount {
            self.activeSignatures = self.signatures ?? []
        }
    }
    
    func vaultsCount() -> Int {
        return signatures?.count ?? 0
    }
    
    func split(secret: String, description: String, callBack: ((Bool)->())?) {
        self.description = description
        
        if let _ = readMySecret(description: "\(self.description)") {
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.alreadySavedMessage, okHandler:  { [weak self] in
                self?.splitInternal(secret, callBack: callBack)
            })
            showCommonAlert(model)
        } else {
            splitInternal(secret, callBack: callBack)
        }
    }
    
    func encryptAndDistribute(callBack: ((Bool)->())?) {
        ShareDistributionManager().distributeShares(components, activeSignatures, description: description, callBack: callBack)
    }
    
    func showDeviceLists(callBack: ((Bool)->())?) {
        let model = SceneSendDataModel(signatures: signatures, callBackSignatures: { [weak self] signatures in
            self?.activeSignatures = signatures
            self?.encryptAndDistribute(callBack: { isSuccess in
                callBack?(isSuccess)
            })
        })
        routeTo(.selectDevice, presentAs: .push, with: model)
    }
    
    func requestClaims(_ description: String) {
        DistributionConnectorManager.shared.startMonitoringClaimResponses(description: description)
    }
}

private extension AddSecretViewModel {
    func splitInternal(_ secret: String, callBack: ((Bool)->())?) {
        components = RustTransporterManager().split(secret: secret)
        callBack?(!components.isEmpty)
    }
    
    //MARK: - WORK WITH DB    
    func readMySecret(description: String) -> Secret? {
        return DBManager.shared.readSecretBy(description: description)
    }
}
