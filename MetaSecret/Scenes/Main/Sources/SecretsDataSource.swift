//
//  SecretsDataSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class SecretsDataSource: MainScreeSourcable {
    func getDataSource<T>(for secrets: T) -> MainScreenSource? {
        guard let secrets = secrets as? [Secret] else {
            return nil
        }
        
        var sourceItems = [[CellSetupDate]]()
        var items = [CellSetupDate]()
        for secret in secrets {
            let cellSource = CellSetupDate()
            cellSource.setupCellSource(title: secret.secretName, boolValue: secret.shares.count != 1)
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
