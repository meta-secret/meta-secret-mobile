//
//  SplashSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation
import UIKit

protocol SplashSceneProtocol {}

final class SplashSceneViewModel: Alertable, UD, Routerable {
    
    private var delegate: SplashSceneProtocol? = nil
    
    //MARK: - INIT
    init(delegate: SplashSceneProtocol) {
        self.delegate = delegate
    }
    
    //MARK: - PUBLIC METHODS
    func chooseStartingScreen() {
        guard deviceStatus == .member else {
            if shouldShowOnboarding {
                routeTo(.onboarding, presentAs: .root)
            } else {
                routeTo(.login, presentAs: .root)
            }
            return
        }
        
        routeTo(.main, presentAs: .root)
    }
}
