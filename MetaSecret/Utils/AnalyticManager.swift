//
//  AnalyticManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.02.2023.
//

import Foundation
import FirebaseAnalytics

protocol AnalyticManagerProtocol {
    func event(name: AnalyticsEvent, params: [AnalyticsProperty: Any])
    func event(name: AnalyticsEvent)
}

final class AnalyticManager: NSObject, AnalyticManagerProtocol {
    private var userService: UsersServiceProtocol
    
    init(userService: UsersServiceProtocol) {
        self.userService = userService
        super.init()
    }
    
    func event(name: AnalyticsEvent) {
        event(name: name, params: [AnalyticsProperty: Any]())
    }
    
    func event(name: AnalyticsEvent, params: [AnalyticsProperty: Any]) {
        var parameters = [String: Any]()
        for (key, value) in params {
            parameters[key.rawValue] = value
        }
        
        if let userName = userService.mainVault?.vaultName, let userDevice = userService.userSignature?.device.deviceName {
            parameters["userName"] = userName
            parameters["userDevice"] = userDevice
        }
        
        Analytics.logEvent(name.rawValue, parameters: parameters)
    }
}

enum AnalyticsProperty: String {
    case OnBoardingPage
    case UserName
    case SelectorTab
}

enum AnalyticsEvent: String {
    case OnboardingShow
    case OnboardingSkip
    case OnboardingNext
    case OnboardingFinish
    case LoginStart
    case LoginExist
    case LoginExistCancel
    case LoginRouteNext
    case LoginAwait
    case MainShow
    case MainStartNeedDBRedistribution
    case SelectorTapped
    case AddDevice
    case AddSecret
    case AddDeviceAccept
    case AddDeviceDecline
    case AddSecretShow
    case SplitSecret
    case RestoreSecret
}
