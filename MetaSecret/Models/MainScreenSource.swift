//
//  MainScreenSource.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

final class MainScreenSource {
    var items: [[CellSetupDate]] = []
}

enum MainScreenSourceType: Int {
    case Secrets
    case Devices
    case None
}
