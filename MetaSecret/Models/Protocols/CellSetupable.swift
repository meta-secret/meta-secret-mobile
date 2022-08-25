//
//  CellSetupable.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import Foundation

protocol CellSetupable {
    var title: String? { get set }
    var subtitle: String? { get set }
    var intValue: Int? { get set }
    
    mutating func setupCellSource(title: String?, subtitle: String?, intValue: Int?)
}

extension CellSetupable {
    var title : String? {
        get { return self.title }
        set { self.title = newValue }
    }
    
    var subtitle : String? {
        get { return self.subtitle }
        set { self.subtitle = newValue }
    }
    
    var intValue : Int? {
        get { return self.intValue }
        set { self.intValue = newValue }
    }
}

struct CellSetupDataSoure: CellSetupable {
    mutating func setupCellSource(title: String? = nil, subtitle: String? = nil, intValue: Int? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.intValue = intValue
    }
}
