//
//  MainSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation
import RealmSwift

protocol MainSceneProtocol {
    func reloadData(source: MainScreenSource?)
}

final class MainSceneViewModel: Alertable, Routerable, UD, Signable, JsonSerealizable {
    //MARK: - PROPERTIES
    private var delegate: MainSceneProtocol? = nil
    private var pendings: [VaultDoc]? = nil
    private var source: MainScreenSource? = nil
    private var type: MainScreenSourceType = .Secrets
//    private var distributionService: DistributionConnectorManagerProtocol
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol/*, distributionService: DistributionConnectorManagerProtocol*/) {
        self.delegate = delegate
//        self.distributionService = distributionService
    }
    
    //MARK: - PUBLIC METHODS (Changing source)
    func getAllLocalSecrets() {
        source = SecretsDataSource().getDataSource(for: DBManager.shared.getAllSecrets())
        delegate?.reloadData(source: source)
        print("## LOCAL SECRETS RELOADED")
    }
    
    func startMonitoringSharesAndClaimRequests() {
        DistributionConnectorManager.shared.startMonitoringSharesAndClaimRequests()
    }
    
    func getVault() {
        DistributionConnectorManager.shared.getVault()
    }
    
    func reDistribue() {
        DistributionConnectorManager.shared.reDistribute()
    }
    
    func getLocalVaultMembers() {
        guard let mainVault else { return }
        self.source = DevicesDataSource().getDataSource(for: mainVault)
        
        guard let source = self.source else { return }
        delegate?.reloadData(source: source)
        print("## LOCAL VAULT MEMBERS RELOADED")
    }
    
    func startMonitoringVaultsToConnect() {
        DistributionConnectorManager.shared.startMonitoringVaults()
    }
    
    func getNewDataSource(type: MainScreenSourceType) {
        self.type = type
        switch type {
        case .Secrets:
            print("## DATA SOURCE CHANGED TO SECRETS")
            getAllLocalSecrets()
        case .Devices:
            print("## DATA SOURCE CHANGED TO DEVICES")
            getLocalVaultMembers()
        default:
            break
        }
    }
}
