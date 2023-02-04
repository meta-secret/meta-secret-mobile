//
//  SplashSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit
import LocalAuthentication

class SplashSceneView: CommonSceneView {
    //MARK: - OUTLETS
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - PROPERTIES
    private let router: ApplicationRouterProtocol
    private let context = LAContext()
    private var isSecureAuth = false
    
    //MARK: - INITIALISATION
    init(messagesManager: Alertable,
         router: ApplicationRouterProtocol
    ) {
        self.router = router
        super.init(alertManager: messagesManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        checkBiometricAllow()
    }
    
    func checkBiometricAllow() {
        var error: NSError?
        let reason = Constants.Alert.biometricalReason
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.router.route()
                    } else {
                        self?.alertManager.showCommonAlert(AlertModel(title: Constants.Errors.authError, message: Constants.Errors.authErrorMessage))
                    }
                }
            }
        } else {
            self.router.route()
        }
    }
}
