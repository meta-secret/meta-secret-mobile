//
//  LoginSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import UIKit
import PromiseKit

class LoginSceneView: CommonSceneView, LoginSceneProtocol {
    //MARK: - OUTLETS
    private struct Config {
        static let cornerRadius = 16
        static let fontSizePopup: CGFloat = 28
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var letsGoButton: UIButton!
    
    // MARK: - Properties
    var viewModel: LoginSceneViewModel
    
    override var commonViewModel: CommonViewModel {
        return viewModel
    }
    
    private var userService: UsersServiceProtocol
    private let routerService: ApplicationRouterProtocol
    private let factory: UIFactoryProtocol
    
    // MARK: - Lifecycle
    init(viewModel: LoginSceneViewModel, userService: UsersServiceProtocol, routerService: ApplicationRouterProtocol, alertManager: Alertable, factory: UIFactoryProtocol) {
        self.viewModel = viewModel
        self.userService = userService
        self.routerService = routerService
        self.factory = factory
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        internalSetupUI()
    }
    
    //MARK: - ACTIONS
    @IBAction func letsGoAction(_ sender: Any) {
        alertManager.showLoader()

        guard let userName = userNameTextField.text, !userName.isEmpty else {
            let alertModel = AlertModel(title: Constants.Errors.error, message: Constants.Errors.enterName)
            alertManager.showCommonAlert(alertModel)
            alertManager.hideLoader()
            return
        }
        
        guard !viewModel.isLoadingData else { return }
        firstly {
            viewModel.preRegistrationChecking(userName)
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
            self.didFailLoadingData(message: e)
        }.finally {
            self.didFinishLoadingData()
        }
    }
    
    //MARK: - VM DELEGATE
    func resetTextField() {
        userNameTextField.text = nil
    }

    func alreadyExisted() {
        didFinishLoadingData()
        alertManager.showCommonAlert(AlertModel(title: Constants.Alert.emptyTitle, message: Constants.LoginScreen.alreadyExisted, okHandler: { [weak self] in
            guard let self,
                  let securityBox = self.userService.securityBox,
                  let userSignature = self.userService.userSignature else { return }
            self.alertManager.showLoader()
            let _ = self.viewModel.register(userSignature, securityBox, isOwner: false)
        }, cancelHandler: { [weak self] in
            self?.userService.resetAll()
        }))
    }
    
    func routeNext() {
        routerService.route()
    }
    
    func showPendingPopup() {
        let model = BottomInfoSheetModel(title: Constants.LoginScreen.awaitingTitle, message: Constants.LoginScreen.awaitingMessage, isClosable: false)
        let controller = factory.popUpHint(with: model)
        popUp(controller)
    }
    
    func showAwaitingAlert() {
        alertManager.showCommonAlert(AlertModel(title: Constants.Errors.warning, message: Constants.LoginScreen.chooseAnotherName, okButton: Constants.LoginScreen.renameOk, okHandler: { [weak self] in
            self?.userService.resetAll()
            self?.resetTextField()
        }, cancelHandler: { [weak self] in
            self?.userService.deviceStatus = .Unknown
            return
        }))
    }
    
    func failed(with error: Error) {
        alertManager.showCommonError(error.localizedDescription)
    }
    
    func closePopUp() {
        guard let vc = findTop(), let popupVC = vc as? PopupHintViewScene else {
            return
        }
        popupVC.closeHint()
    }
}

private extension LoginSceneView {
    //MARK: - UI SETUP
    func internalSetupUI() {
        userNameTextField.delegate = self
        topView.roundCorners(corners: [.topLeft, .topRight], radius: Config.cornerRadius)
        containerView.showShadow()
        
        userNameTextField.placeholder = Constants.LoginScreen.userNameLabel
        loginTitle.text = Constants.LoginScreen.loginTitle
        letsGoButton.setTitle(Constants.LoginScreen.letsGoButton, for: .normal)
        letsGoButton.setTitle(Constants.LoginScreen.letsGoButton, for: .disabled)
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textFieldDidChange(userNameTextField)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGR)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            letsGoButton.isUserInteractionEnabled = true
            letsGoButton.backgroundColor = AppColors.mainBlack
        } else {
            letsGoButton.isUserInteractionEnabled = false
            letsGoButton.backgroundColor = AppColors.mainGray
        }
    }
    
    @objc func hideKeyboard() {
        userNameTextField.resignFirstResponder()
    }
}

//MARK: - TEXT FIELD DELEGATE
extension LoginSceneView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
