//
//  DevicesDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class DevicesDataSource: MainScreeSourcable, UD {
    func getDataSource<T>(for vault: T) -> MainScreenSource? {
        guard let vault = vault as? Vault else {
            return nil
        }
        
        var sourceItems = [[CellSetupDate]]()
        var pendingItems = [CellSetupDate]()
        var declinedItems = [CellSetupDate]()
        var memberItems = [CellSetupDate]()
        var virtualVaults = [CellSetupDate]()
        
        for item in vault.pendingJoins ?? [] {
            
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.pending.rawValue, intValue: MainScreenSourceType.Secrets.rawValue, status: .pending, boolValue: true, id: item.device?.deviceId)
            pendingItems.append(cellSource)
        }
        sourceItems.append(pendingItems)
        
        for item in vault.declinedJoins ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.declined.rawValue, intValue: MainScreenSourceType.Secrets.rawValue, status: .declined, id: item.device?.deviceId)
            declinedItems.append(cellSource)
        }
        sourceItems.append(declinedItems)
        
        for item in vault.signatures ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: item.device?.deviceName, subtitle: VaultInfoStatus.member.rawValue, intValue: MainScreenSourceType.Secrets.rawValue, status: .member, id: item.device?.deviceId)
            memberItems.append(cellSource)
        }
        sourceItems.append(memberItems)
        
        let source = MainScreenSource()
        source.items = sourceItems
        return source
    }
    
}
