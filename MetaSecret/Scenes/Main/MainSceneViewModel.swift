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
    private var distributionService: DistributionConnectorManagerProtocol
    
    //MARK: - INIT
    init(delegate: MainSceneProtocol, distributionService: DistributionConnectorManagerProtocol) {
        self.delegate = delegate
        self.distributionService = distributionService
    }
    
    //MARK: - PUBLIC METHODS (Changing source)
    func getAllSecrets() {
        source = SecretsDataSource().getDataSource(for: DBManager.shared.getAllSecrets())
        delegate?.reloadData(source: source)
        distributionService.startMonitoringShares()
    }
    
    func getVault() {
        guard let mainVault else { return }
        self.source = DevicesDataSource().getDataSource(for: mainVault)
        
        guard let source = self.source else { return }
        delegate?.reloadData(source: source)
        distributionService.startMonitoringDevices()
    }
    
    func getNewDataSource(type: MainScreenSourceType) {
        self.type = type
        switch type {
        case .Secrets:
            getAllSecrets()
        case .Devices:
            getVault()
        default:
            break
        }
    }
}
