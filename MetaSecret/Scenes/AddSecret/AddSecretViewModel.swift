//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import PromiseKit

protocol AddSecretProtocol {
    func close()
    func showRestoreResult(password: String?)
}

final class AddSecretViewModel: CommonViewModel {
    //MARK: - PROPERTIES
    enum Config {
        static let minMembersCount = 3
    }
    
    private var components: [UserShareDto] = [UserShareDto]()
    private var signatures: [UserSignature]? = nil
    private var description: String = ""
    private lazy var activeSignatures: [UserSignature] = [UserSignature]()
    
    private var userService: UsersServiceProtocol
    private var shareDistributionManager: ShareDistributionProtocol
    private var dbManager: DBManagerProtocol
    private var rustManager: RustProtocol
    private var alertManager: Alertable
    private var distriButionManager: DistributionConnectorManagerProtocol
    
    var modeType: ModeType = .edit
    var delegate: AddSecretProtocol? = nil
    
    override var title: String {
        return modeType == .readOnly ? Constants.AddSecret.titleEdit : Constants.AddSecret.title
    }
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol,
         shareDistributionManager: ShareDistributionProtocol,
         dbManager: DBManagerProtocol,
         rustManager: RustProtocol,
         alertManager: Alertable,
         distriButionManager: DistributionConnectorManagerProtocol) {
        self.userService = userService
        self.dbManager = dbManager
        self.shareDistributionManager = shareDistributionManager
        self.alertManager = alertManager
        self.rustManager = rustManager
        self.distriButionManager = distriButionManager
    }
    
    override func loadData() -> Promise<Void> {
        isLoadingData = true
        return firstly {
            getVault()
        }.ensure {
            self.isLoadingData = false
        }.asVoid()
    }
    
    //MARK: - PUBLIC METHODS
    func getVault() -> Promise<Void> {
        self.signatures?.removeAll()
        self.signatures = userService.mainVault?.signatures
        if self.signatures?.count ?? 0 <= Constants.Common.neededMembersCount {
            self.activeSignatures = self.signatures ?? []
        }
        return Promise().asVoid()
    }
    
    func vaultsCount() -> Int {
        return signatures?.count ?? 0
    }
    
    func split(secret: String, description: String) -> Promise<Void> {
        self.description = description
        
        if let _ = readMySecret(description: description) {
            return Promise(error: MetaSecretErrorType.alreadySavedMessage)
        } else {
            return splitInternal(secret)
        }
    }
    
    

    func encryptAndDistribute() -> Promise<Void> {
        return shareDistributionManager.distributeShares(components, activeSignatures, description: description)
    }
    
    func showDeviceLists() -> Promise<Void> {
//        let model = SceneSendDataModel(signatures: signatures, callBackSignatures: { [weak self] signatures in
//            self?.activeSignatures = signatures
//            self?.encryptAndDistribute()
//        })
//        routeTo(.selectDevice, presentAs: .push, with: model)
        return Promise().asVoid()
    }
    
    func requestClaims(_ description: String) {
        distriButionManager.startMonitoringClaimResponses(description: description)
    }
}

private extension AddSecretViewModel {
    func splitInternal(_ secret: String) -> Promise<Void> {
        components = rustManager.split(secret: secret)
        if components.isEmpty {
            return Promise(error: MetaSecretErrorType.splitError)
        }
        return Promise().asVoid()
    }
    
    //MARK: - WORK WITH DB    
    func readMySecret(description: String) -> Secret? {
        return dbManager.readSecretBy(description: description)
    }
}
