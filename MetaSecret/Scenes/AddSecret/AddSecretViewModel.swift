//
//  AddSecretViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.08.2022.
//

import Foundation
import UIKit

protocol AddSecretProtocol {}

final class AddSecretViewModel: Alertable, UD, Routerable {
    
    private var delegate: AddSecretProtocol? = nil
    
    //MARK: - INIT
    init(delegate: AddSecretProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func saveMySecrete() {
        
    }
}
