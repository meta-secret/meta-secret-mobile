//
//  MainScreenSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

class MainScreenSource {
    var items: [[CellSetupDate]] = []
}

enum MainScreenSourceType: Int {
    case Vaults
    case Devices
    case None
}
