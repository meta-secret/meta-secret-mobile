//
//  BottomInfoViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 10.09.2022.
//

import Foundation

protocol BottomInfoProtocol {
    func successFullConnection()
}

final class BottomInfoViewModel {
    
    private var delegate: BottomInfoProtocol? = nil
    
    
    //MARK: - INIT
    init(delegate: BottomInfoProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    
}
