//
//  OnboardingSceneViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 30.12.2022.
//

import Foundation

class OnboardingSceneViewModel: CommonViewModel {
    override init() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var cells: [CellType] = [.cloud, .distributed, .backup, .passwordLess]
    
    var pagesCount: Int {
        return cells.count
    }
    
    var cellsCount: Int {
        return cells.count
    }
}

extension OnboardingSceneViewModel {
    enum CellType {
        case welcome
        case cloud
        case distributed
        case passwordLess
        case backup
        
        var title: String {
            switch self {
            case .welcome:
                return Constants.Onboarding.welcome
            case .cloud:
                return Constants.Onboarding.personalCloud
            case .distributed:
                return Constants.Onboarding.distributedStorage
            case .passwordLess:
                return Constants.Onboarding.passwordLess
            case .backup:
                return Constants.Onboarding.backup
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return Constants.Onboarding.whatIs
            case .cloud:
                return Constants.Onboarding.personalCloudDescription
            case .distributed:
                return Constants.Onboarding.distributedStorageDescription
            case .passwordLess:
                return Constants.Onboarding.passwordLessDescription
            case .backup:
                return Constants.Onboarding.backupDescription
            }
        }
    }
}
