//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import PromiseKit
import LocalAuthentication

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
    private var descriptionName: String = ""
    private lazy var activeSignatures: [UserSignature] = [UserSignature]()
    
    private var userService: UsersServiceProtocol
    private var dbManager: DBManagerProtocol
    private var rustManager: RustProtocol
    private var distributionManager: DistributionProtocol
    private var alertManager: Alertable
    
    var model: SceneSendDataModel? = nil
    var delegate: AddSecretProtocol? = nil
    
    var modeType: ModeType {
        return model?.modeType ?? .edit
    }
    
    var descriptionText: String {
        return model?.mainStringValue ?? ""
    }
    
    var descriptionHeaderText: String {
        return modeType == .edit ? Constants.AddSecret.addDescriptionTitle : Constants.AddSecret.description
    }
    
    var addPasswordHeaderText: String {
        return modeType == .edit ? Constants.AddSecret.addPassword : Constants.AddSecret.password
    }
    
    override var title: String {
        return modeType == .readOnly ? Constants.AddSecret.recoverEdit : Constants.AddSecret.title
    }
    
    //MARK: - INIT
    init(userService: UsersServiceProtocol,
         dbManager: DBManagerProtocol,
         rustManager: RustProtocol,
         distributionManager: DistributionProtocol,
         alertManager: Alertable) {
        self.userService = userService
        self.dbManager = dbManager
        self.rustManager = rustManager
        self.distributionManager = distributionManager
        self.alertManager = alertManager
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
    
    func split(secret: String, descriptionName: String) -> Promise<Void> {
        self.descriptionName = descriptionName
        
        if let _ = readMySecret(descriptionName: descriptionName) {
            return Promise(error: MetaSecretErrorType.alreadySavedMessage)
        } else {
            return splitInternal(secret)
        }
    }
    
    func stopRestoring() {
        distributionManager.stopMonitoringClaimResponses()
    }
    
    func encryptAndDistribute() -> Promise<Void> {
        return distributionManager.distributeShares(components, activeSignatures, descriptionName: descriptionName)
    }
    
    func showDeviceLists() -> Promise<Void> {
//        let model = SceneSendDataModel(signatures: signatures, callBackSignatures: { [weak self] signatures in
//            self?.activeSignatures = signatures
//            self?.encryptAndDistribute()
//        })
//        routeTo(.selectDevice, presentAs: .push, with: model)
        return Promise().asVoid()
    }
    
    func restore(descriptionName: String) {
        checkBiometricAllow(descriptionName)
    }
    
    private func checkBiometricAllow(_ descriptionName: String) {
        let context = LAContext()
        var error: NSError?
        let reason = Constants.Alert.biometricalReason
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.alertManager.showLoader()
                        self?.requestClaims(descriptionName)
                    } else {
                        self?.alertManager.showCommonAlert(AlertModel(title: Constants.Errors.authError, message: Constants.Errors.authErrorMessage))
                    }
                }
            }
        } else {
            requestClaims(descriptionName)
        }
    }
    
    func requestClaims(_ descriptionName: String) {
        distributionManager.startMonitoringClaimResponses(descriptionName: descriptionName)
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
    func readMySecret(descriptionName: String) -> Secret? {
        return dbManager.readSecretBy(descriptionName: descriptionName)
    }
}
