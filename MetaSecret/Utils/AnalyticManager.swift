//
//  AnalyticManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.02.2023.
//

import Foundation
import FirebaseAnalytics
import YandexMobileMetrica

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
        var parametersF = [String : Any]()
        var parametersY = [AnyHashable : Any]()
        for (key, value) in params {
            parametersF[key.rawValue] = value
            parametersY[key.rawValue] = value
        }
        
        if let userName = userService.mainVault?.vaultName {
            parametersF["userName"] = userName
            parametersY["userName"] = userName
        }
        
        if let userDevice = userService.userSignature?.device.deviceName {
            parametersF["userDevice"] = userDevice
            parametersY["userDevice"] = userDevice
        }
        
        if let devicesCount = userService.mainVault?.signatures?.count {
            parametersF["devicesCount"] = devicesCount
            parametersY["devicesCount"] = devicesCount
        }
        
        Analytics.logEvent(name.rawValue, parameters: parametersF)
        YMMYandexMetrica.reportEvent(name.rawValue, parameters: parametersY)
        
    }
}

enum AnalyticsProperty: String {
    case OnBoardingPage
    case UserName
    case SelectorTab
    case DevicesInCluster
}

enum AnalyticsEvent: String {
    case OnboardingShow = "Onbording Started"
    case OnboardingSkip = "Onbording Skip Pressed"
    case OnboardingNext = "Onbording Next Pressed"
    case OnboardingFinish = "Onbording Complited"
    case LoginStart = "Login Screen Showed"
    case LoginExist = "Name Exist Alert"
    case LoginExistCancel = "Cancel Current Name"
    case LoginRouteNext = "Login Complited"
    case LoginAwait = "Waiting Name Confirmation"
    case MainShow = "Main Screen Showed"
    case MainStartNeedDBRedistribution = "Need Full DB Redistribution"
    case SelectorTapped = "Tab Changed"
    case AddDevice = "Add Device Instruction Showed"
    case AddSecret = "Add Secret Tapped"
    case AddDeviceAccept = "Accept Device "
    case AddDeviceDecline = "Decline Device"
    case AddSecretShow = "AddSecret Screen Showed"
    case SplitSecret = "Secret Split"
    case RestoreSecret = "Secret Restore"
}
