//
//  ApplicationAssembly.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import Swinject
import SwinjectAutoregistration

class ApplicationAssembly: Assembly {
    func assemble(container: Container) {
        setContainerLoggingFunction()
        registerWindow(in: container)
        registerViewModels(in: container)
        registerViewControllers(in: container)
    }
}

extension ApplicationAssembly {
    func registerWindow(in container: Container) {
        container.register(UIWindow.self) { r in
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.makeKeyAndVisible()
            return window
        }.inObjectScope(.container)
    }
}

extension ApplicationAssembly {
    func registerViewControllers(in container: Container) {
        container.autoregister(SplashSceneView.self, initializer: SplashSceneView.init)
        container.autoregister(OnboardingSceneView.self, initializer: OnboardingSceneView.init)
        container.autoregister(LoginSceneView.self, initializer: LoginSceneView.init)
        container.autoregister(PopupHintViewScene.self, initializer: PopupHintViewScene.init)
        container.autoregister(MainSceneView.self, initializer: MainSceneView.init)
        container.autoregister(DeviceInfoSceneView.self, initializer: DeviceInfoSceneView.init)
        container.autoregister(AddSecretSceneView.self, initializer: AddSecretSceneView.init)
        container.autoregister(SelectDeviceSceneView.self, initializer: SelectDeviceSceneView.init)
        container.autoregister(BottomInfoSheetViewScene.self, initializer: BottomInfoSheetViewScene.init)
    }
}

extension ApplicationAssembly {
    func registerViewModels(in container: Container) {
        container.autoregister(OnboardingSceneViewModel.self, initializer: OnboardingSceneViewModel.init)
        container.autoregister(LoginSceneViewModel.self, initializer: LoginSceneViewModel.init)
        container.autoregister(MainSceneViewModel.self, initializer: MainSceneViewModel.init)
        container.autoregister(DeviceInfoSceneViewModel.self, initializer: DeviceInfoSceneViewModel.init)
        container.autoregister(AddSecretViewModel.self, initializer: AddSecretViewModel.init)
        container.autoregister(SelectDeviceViewModel.self, initializer: SelectDeviceViewModel.init)
        container.autoregister(BottomInfoViewModel.self, initializer: BottomInfoViewModel.init)
    }
}

extension ApplicationAssembly {
    private func setContainerLoggingFunction() {
        Container.loggingFunction = {
            
            // Find the text that contains the missing registration.
            if let startOfMissingRegistration = $0.range(of: "Swinject: Resolution failed. Expected registration:\n\t")?.upperBound,
               let startOfAvailableOptions = $0.range(of: "\nAvailable registrations:")?.lowerBound {
                let missingRegistration = $0[startOfMissingRegistration ..< startOfAvailableOptions]
                
                // Ignore all reports for UIKit classes.
                if missingRegistration.contains("Storyboard: UI")
                    || missingRegistration.contains("Storyboard: MyApp.IgnoreThisViewController")
                /* || other classes you want to ignore here */  {
                    return
                }
                
                // Print the missing registration.
                print("Swinject failed to find registration for \(missingRegistration)")
                return
            }
            
            // Some other message so just print it.
            print($0)
        }
    }
}
