//
//  LoginSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import UIKit

class LoginSceneView: UIViewController, LoginSceneProtocol, Routerable, UD {
    //MARK: - OUTLETS
    private struct Config {
        static let cornerRadius = 16
        static let fontSizePopup: CGFloat = 28
    }
    
    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var letsGoButton: UIButton!
    
    //MARK: - PROPERTIES
    private var viewModel: LoginSceneViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoading()
        setupUI()
        
        self.viewModel = LoginSceneViewModel(delegate: self)
    }
    
    //MARK: - ACTIONS
    @IBAction func letsGoAction(_ sender: Any) {
        self.showLoading()

        guard let userName = userNameTextField.text, !userName.isEmpty else {
            viewModel?.showAlert(message: Constants.Errors.enterName)
            hideLoading()
            return
        }
        
        viewModel?.register(userName)
    }
    
    //MARK: - VM DELEGATE
    func resetTextField() {
        userNameTextField.text = nil
    }
    
    func processFinished() {
        hideLoading()
    }
    
    func showPendingPopup() {
        let model = BottomInfoSheetModel(title: Constants.LoginScreen.awaitingTitle, message: Constants.LoginScreen.awaitingMessage, isClosable: false)
        routeTo(.popupHint, presentAs: .presentFullScreen, with: model)
    }
}

private extension LoginSceneView {
    //MARK: - UI SETUP
    func setupUI() {
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
    
    func showLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        userNameTextField.isUserInteractionEnabled = false
        letsGoButton.isUserInteractionEnabled = false
        letsGoButton.backgroundColor = AppColors.mainGray
    }
    
    func hideLoading() {
        activityIndicator.isHidden = true
        userNameTextField.isUserInteractionEnabled = true
        textFieldDidChange(userNameTextField)
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
