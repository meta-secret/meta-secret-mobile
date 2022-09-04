//
//  Router.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import Foundation
import UIKit

enum SceneName {
    case login
    case main
    case split
    case deviceInfo
}

enum PresentType {
    case push
    case present
    case root
}

protocol Routerable: RootFindable {
    func routeTo(_ screen: SceneName, presentAs: PresentType, with data: Any?)
}

extension Routerable {
    func routeTo(_ screen: SceneName, presentAs: PresentType = .push, with data: Any? = nil) {
        let nextScene = getNextScreen(screen)
        let root = findRoot()
        
        switch presentAs {
        case .push:
            (nextScene as? DataSendable)?.dataSent = data
            root?.navigationController?.pushViewController(nextScene, animated: true)
        case .present:
            (nextScene as? DataSendable)?.dataSent = data
            root?.navigationController?.present(nextScene, animated: true)
        case .root:
            (nextScene as? DataSendable)?.dataSent = data
            root?.navigationController?.setViewControllers([nextScene], animated: true)
        }
    }
    
    private func getNextScreen(_ screen: SceneName) -> UIViewController {
        switch screen {
        case .login:
            return LoginSceneView(nibName: "LoginSceneView", bundle: nil)
        case .main:
            return MainSceneView(nibName: "MainSceneView", bundle: nil)
        case .split:
            return AddSecretSceneView(nibName: "AddSecretSceneView", bundle: nil)
        case .deviceInfo:
            return DeviceInfoSceneView(nibName: "DeviceInfoSceneView", bundle: nil)
        }
    }
}

protocol DataSendable: AnyObject {
    var dataSent: Any? { get set }
}
