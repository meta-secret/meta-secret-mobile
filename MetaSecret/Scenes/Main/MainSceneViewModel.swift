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
    static let minDevicesCount = 3
    
    var emptyStatusText: String {
        return selectedSegment.rawValue == 0 ? Constants.MainScreen.noSecrets : ""
    }
    
    var remainingNotificationContainerHidden: Bool {
        return selectedSegment == .Secrets || !userService.isOwner
    }
    
    var addDeviceViewHidden: Bool {
        return selectedSegment == .Devices && (filteredSourceArrayCount() > Self.minDevicesCount)
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
    init(dbManager: DBManagerProtocol, distributionManager: DistributionProtocol, userService: UsersServiceProtocol) {
        self.dbManager = dbManager
        self.userService = userService
        self.distributionManager = distributionManager
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
                self.checkVaultResult()
            }.asVoid()
        }
    }
    
    private func checkVaultResult() -> Promise<Void> {
        guard let mainVault = userService.mainVault else { return Promise(error: MetaSecretErrorType.vaultError) }
        source = DevicesDataSource().getDataSource(for: mainVault)
        return Promise().asVoid()
    }
    
    private func checkShares() -> Promise<Void> {
        return distributionManager.findShares()
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

    func startMonitoringSharesAndClaimRequests() {
        distributionManager.startMonitoringSharesAndClaimRequests()
    }
    
    func startMonitoringVaultsToConnect() {
        distributionManager.startMonitoringVaults()
    }

    func reDistribue() -> Promise<Void> {
        return distributionManager.reDistribute()
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
        let filteredArr = flatArr?.filter({$0.subtitle?.lowercased() == VaultInfoStatus.member.rawValue.lowercased()})
        
        guard let count = filteredArr?.count, count < Self.minDevicesCount else { return 0 }
        return count
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
