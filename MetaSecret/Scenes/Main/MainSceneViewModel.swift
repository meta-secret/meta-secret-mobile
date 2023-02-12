//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation
import RealmSwift
import PromiseKit

protocol MainSceneProtocol {}

final class MainSceneViewModel: CommonViewModel {
    //MARK: - PROPERTIES
    var delegate: MainSceneProtocol? = nil
    var source: MainScreenSource? = nil
    var selectedSegment: MainScreenSourceType = .Secrets
    var isToReDistribute = false
    
    private var pendings: [VaultDoc]? = nil
    private var dbManager: DBManagerProtocol
    private var userService: UsersServiceProtocol
    private var distributionManager: DistributionProtocol
    private var vaultApiService: VaultAPIProtocol
    private var biometricManager: BiometricsManagerProtocol
    private var alertManager: Alertable
    private var rustManager: RustProtocol
    private var currentSecretIndex: Int = 0
    
    var emptyStatusText: String {
        return selectedSegment.rawValue == 0 ? Constants.MainScreen.noSecrets : ""
    }
    
    var remainingNotificationContainerHidden: Bool {
        return selectedSegment == .Secrets || !userService.isOwner || userService.mainVault?.signatures?.count ?? 0 >= Constants.Common.neededMembersCount
    }
    
    var addDeviceViewHidden: Bool {
        return selectedSegment == .Devices && (filteredSourceArrayCount() > Constants.Common.neededMembersCount)
    }
    
    var remainingDevicesText: String {
        return Constants.MainScreen.addDevices(memberCounts: filteredSourceArrayCount())
    }
    
    var yourDeviceTitle: String {
        return selectedSegment == .Secrets ? Constants.MainScreen.yourSecrets : Constants.MainScreen.yourDevices
    }
    
    override var title: String {
        return selectedSegment.rawValue == 0 ? Constants.MainScreen.secrets : Constants.MainScreen.devices
    }
    
    //MARK: - INIT
    init(dbManager: DBManagerProtocol, distributionManager: DistributionProtocol, userService: UsersServiceProtocol, vaultApiService: VaultAPIProtocol, biometricManager: BiometricsManagerProtocol, alertManager: Alertable, rustManager: RustProtocol) {
        self.dbManager = dbManager
        self.userService = userService
        self.distributionManager = distributionManager
        self.vaultApiService = vaultApiService
        self.biometricManager = biometricManager
        self.alertManager = alertManager
        self.rustManager = rustManager
    }
    
    override func loadData() -> Promise<Void> {
        isLoadingData = true
        return firstly {
            when(fulfilled: [self.getAllLocalSecrets(), checkShares(), getVault()])
        }.get { result in
            self.isLoadingData = false
            self.startMonitoringVaultsToConnect()
            self.startMonitoringSharesAndClaimRequests()
        }.asVoid()
    }
    
    //MARK: - PUBLIC METHODS (Pairing)
    func acceptUser(candidate: UserSignature) -> Promise<Void> {
        return firstly{
            vaultApiService.accept(candidate)
        }.then { result in
            self.checkResult(result: result)
        }.asVoid()
    }
    
    func declineUser(candidate: UserSignature) -> Promise<Void> {
        return firstly{
            vaultApiService.decline(candidate)
        }.then { result in
            self.checkResult(result: result)
        }.asVoid()
    }
    
    private func checkResult(result: AcceptResult) -> Promise<Void> {
        guard result.msgType == Constants.Common.ok else { return Promise(error: MetaSecretErrorType.networkError) }
        return Promise().asVoid()
    }
    
    //MARK: - PUBLIC METHODS (Changing source)
    func getAllLocalSecrets() -> Promise<Void> {
        source = SecretsDataSource().getDataSource(for: dbManager.getAllSecrets())
        return Promise().asVoid()
    }
    
    func getLocalVaultMembers() -> Promise<Void> {
        if let mainVault = userService.mainVault {
            source = DevicesDataSource().getDataSource(for: mainVault)
            return Promise().asVoid()
        } else {
            return firstly {
                getVault()
            }.get {
                let _ = self.checkVaultResult()
            }.asVoid()
        }
    }
    
    private func checkVaultResult() -> Promise<Void> {
        guard let mainVault = userService.mainVault else { return Promise(error: MetaSecretErrorType.vaultError) }
        source = DevicesDataSource().getDataSource(for: mainVault)
        return Promise().asVoid()
    }
    
    private func checkShares() -> Promise<Void> {
        return distributionManager.findShares(type: .Split)
    }
    
    func getVault() -> Promise<Void> {
        return distributionManager.getVault()
    }
    
    func selectedDevice(content: CellSetupDate) -> UserSignature? {
        let declines = userService.mainVault?.declinedJoins ?? []
        let pendings = userService.mainVault?.pendingJoins ?? []
        let signatures = userService.mainVault?.signatures ?? []
        let flattenArray = declines + pendings + signatures
        let selectedItem = flattenArray.first(where: {$0.device.deviceId == content.id })
        return selectedItem
    }
    
    func needDBRedistribution() -> Bool {
        return dbManager.getAllSecrets().first(where: {$0.shares.count == 1}) != nil
    }

    func startMonitoringSharesAndClaimRequests() {
        distributionManager.startMonitoringSharesAndClaimRequests()
    }
    
    func startMonitoringVaultsToConnect() {
        distributionManager.startMonitoringVaults()
    }

    func reDistribue() -> Promise<Void> {
        return distributionManager.reDistribute()
    }
    
    func dbRedistribution(_ secret: String, descriptionName: String) {
        let components = rustManager.split(secret: secret)
        guard !components.isEmpty,
        let signatures = userService.mainVault?.signatures,
        signatures.count <= Constants.Common.neededMembersCount else {
            currentSecretIndex += 1
            dbRedistributionAsk()
            return
        }
        
        let _ = firstly {
            distributionManager.distributeShares(components, signatures, descriptionName: descriptionName)
        }.get {
            self.currentSecretIndex += 1
            self.dbRedistributionAsk()
        }
    }
    
    private func dbRedistributionAsk() {
        let allSecrets = dbManager.getAllSecrets()
        if currentSecretIndex < allSecrets.count {
            let currentSecret = allSecrets[currentSecretIndex]
            distributionManager.startMonitoringClaimResponses(descriptionName: currentSecret.secretName)
        } else {
            alertManager.hideLoader()
            userService.needDBRedistribution = false
            currentSecretIndex = 0
        }
    }
    
    private func evaluation(success: Bool, error: BiometricError?) -> Promise<Void> {
        guard success else {
            return Promise(error: MetaSecretErrorType.alreadySavedMessage)
        }
        dbRedistributionAsk()
        return Promise().asVoid()
    }
    
    private func checEvaluation(_ canEvaluate: Bool) -> Promise<Void> {
        self.alertManager.showLoader()
        guard canEvaluate else {
            dbRedistributionAsk()
            return Promise().asVoid()
        }
        
        return firstly {
            biometricManager.evaluate()
        }.then { success, error in
            self.evaluation(success: success, error: error)
        }.asVoid()
    }
    
    func checkBiometricAllow() -> Promise<Void> {
        return firstly {
            biometricManager.canEvaluate()
        }.then { canEvaluate in
            self.checEvaluation(canEvaluate)
        }.asVoid()
    }

    func getNewDataSource() -> Promise<Void> {
        switch selectedSegment {
        case .Secrets:
            return getAllLocalSecrets()
        case .Devices:
            return getLocalVaultMembers()
        default:
            return Promise().asVoid()
        }
    }
             
    private func filteredSourceArrayCount() -> Int {
        let flatArr = source?.items.flatMap { $0 }
        let filteredArr = flatArr?.filter({$0.subtitle?.lowercased() == VaultInfoStatus.Member.rawValue.lowercased()})
        
        guard let count = filteredArr?.count, count < Constants.Common.neededMembersCount else { return 0 }
        return count
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
