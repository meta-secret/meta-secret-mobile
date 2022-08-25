//
//  VaultsDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class VaultsDataSource: MainScreeSourcable {
    func getDataSource(for vault: Vault) -> MainScreenSource {
        var sourceItems = [CellSetupable]()
        
        for item in vault.pendingJoins ?? [] {
            var cellSource = CellSetupDataSoure()
            
            cellSource.setupCellSource(title: item.deviceName, subtitle: VaultInfoStatus.pending.rawValue, intValue: MainScreenSourceType.Vaults.rawValue)
            sourceItems.append(cellSource)
        }
        
        for item in vault.declinedJoins ?? [] {
            var cellSource = CellSetupDataSoure()
            
            cellSource.setupCellSource(title: item.deviceName, subtitle: VaultInfoStatus.declined.rawValue, intValue: MainScreenSourceType.Vaults.rawValue)
            sourceItems.append(cellSource)
        }
        
        for item in vault.signatures ?? [] {
            var cellSource = CellSetupDataSoure()
            
            cellSource.setupCellSource(title: item.deviceName, subtitle: VaultInfoStatus.member.rawValue, intValue: MainScreenSourceType.Vaults.rawValue)
            sourceItems.append(cellSource)
        }
        
        let source = MainScreenSource()
        source.items.append(contentsOf: sourceItems)
        return source
    }
}
