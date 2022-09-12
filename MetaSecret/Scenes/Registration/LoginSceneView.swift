//
//  LoginSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import UIKit

class LoginSceneView: UIViewController, LoginSceneProtocol {
    //MARK: - OUTLETS
    private struct Config {
        static let cornerRadius = 16
    }
    
    @IBOutlet weak var topView: UIView!
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
        showLoading()
        
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
}

private extension LoginSceneView {
    //MARK: - UI SETUP
    func setupUI() {
        userNameTextField.delegate = self
        topView.roundCorners(corners: [.topLeft, .topRight], radius: Config.cornerRadius)
        containerView.dropShadow()
        letsGoButton.setTitle(Constants.LoginScreen.letsGoButton, for: .normal)
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textFieldDidChange(userNameTextField)
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
}

//MARK: - TEXT FIELD DELEGATE
extension LoginSceneView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
