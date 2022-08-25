//
//  MainScreeSourcable.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

protocol MainScreeSourcable {
    func getDataSource(for result: Vault) -> MainScreenSource
}
