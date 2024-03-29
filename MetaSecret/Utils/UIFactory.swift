//
//  UIFactory.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 01.01.2023.
//

import Foundation
import Swinject

protocol UIFactoryProtocol {
    // Common
    func popUpHint(with model: BottomInfoSheetModel) -> PopupHintViewScene?
    func mainScreen() -> MainSceneView?
    func split(model: SceneSendDataModel) -> AddSecretSceneView?
    func scanner(delegate: ScannerSceneViewDelegate) -> ScannerSceneView?
}

class UIFactory : NSObject, UIFactoryProtocol {
    private let router: ApplicationRouterProtocol
    
    init(router: ApplicationRouterProtocol) {
        self.router = router
    }
}

extension UIFactory {
    func popUpHint(with model: BottomInfoSheetModel) -> PopupHintViewScene? {
        let viewController = router.resolve(PopupHintViewScene.self)
        viewController?.model = model
        return viewController
    }

    func mainScreen() -> MainSceneView? {
        let viewController = router.resolve(MainSceneView.self)
        return viewController
    }
    
    func split(model: SceneSendDataModel) -> AddSecretSceneView? {
        let viewController = router.resolve(AddSecretSceneView.self)
        viewController?.viewModel.model = model
        return viewController
    }
    
    func scanner(delegate: ScannerSceneViewDelegate) -> ScannerSceneView? {
        let viewController = router.resolve(ScannerSceneView.self)
        viewController?.delegate = delegate
        return viewController
    }
}
