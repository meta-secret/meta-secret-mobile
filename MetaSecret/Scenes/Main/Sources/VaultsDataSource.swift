//
//  VaultsDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class VaultsDataSource: MainScreeSourcable {
    func getDataSource<T>(for secrets: T) -> MainScreenSource? {
        guard let secrets = secrets as? [Secret] else {
            return nil
        }
        
        var sourceItems = [[CellSetupDate]]()
        var items = [CellSetupDate]()
        for item in secrets {
            let cellSource = CellSetupDate()
            
//            let isWarning = (!item.isFullySplited || item.isSavedLocaly) ? true : false
            cellSource.setupCellSource(title: item.secretID, boolValue: false)
            items.append(cellSource)
        }
        
        if !items.isEmpty {
            sourceItems.append(items)
        }
        
        let source = MainScreenSource()
        source.items = sourceItems
        return source
    }
}
