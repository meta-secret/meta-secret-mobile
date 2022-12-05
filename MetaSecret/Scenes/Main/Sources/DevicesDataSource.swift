//
//  DevicesDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class DevicesDataSource: MainScreeSourcable, UD {
    func getDataSource<T>(for vault: T) -> MainScreenSource? {
        guard let vault = vault as? VaultDoc else {
            return nil
        }
        
        var sourceItems = [[CellSetupDate]]()
        var pendingItems = [CellSetupDate]()
        var declinedItems = [CellSetupDate]()
        var memberItems = [CellSetupDate]()
        
        for signature in vault.pendingJoins ?? [] {
            
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: signature.device.deviceName, subtitle: VaultInfoStatus.pending.title(), intValue: MainScreenSourceType.Secrets.rawValue, status: .pending, boolValue: true, id: signature.device.deviceId)
            pendingItems.append(cellSource)
        }
        sourceItems.append(pendingItems)
        
        for signature in vault.declinedJoins ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: signature.device.deviceName, subtitle: VaultInfoStatus.declined.title(), intValue: MainScreenSourceType.Secrets.rawValue, status: .declined, id: signature.device.deviceId)
            declinedItems.append(cellSource)
        }
        sourceItems.append(declinedItems)
        
        for signature in vault.signatures ?? [] {
            let cellSource = CellSetupDate()
            
            cellSource.setupCellSource(title: signature.device.deviceName, subtitle: VaultInfoStatus.member.title(), intValue: MainScreenSourceType.Secrets.rawValue, status: .member, id: signature.device.deviceId)
            memberItems.append(cellSource)
        }
        sourceItems.append(memberItems)
        
        let source = MainScreenSource()
        source.items = sourceItems
        return source
    }
    
}
