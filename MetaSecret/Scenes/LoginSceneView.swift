//
//  LoginSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 13.08.2022.
//

import UIKit

class LoginSceneView: UIViewController {
    //MARK: - OUTLETS
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var letsGoButton: UIButton!
    
    //MARK: - PROPERTIES
    private var viewModel: LoginSceneViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.viewModel = LoginSceneViewModel(delegate: self)
    }
    
    //MARK: - ACTIONS
    @IBAction func letsGoAction(_ sender: Any) {
        guard var userName = userNameTextField.text, !userName.isEmpty, userName != "@" else {
            let alertModel = AlertModel(presenter: self, title: Constants.Errors.error, message: Constants.Errors.enterName)
            AlertManager.shared.showAlert(alertModel)
            return
        }
        
        userName = userName.replacingOccurrences(of: "@", with: "")
        guard let user = viewModel?.generateKeys(for: userName) else {
            AlertManager.shared.showCommonError(self, message: nil)
            return
        }
        
        viewModel?.register(user: user)
    }
}

private extension LoginSceneView {
    //MARK: - UI SETUP
    func setupUI() {
        self.title = Constants.LoginScreen.title
        userNameLabel.text = Constants.LoginScreen.userNameLabel
        letsGoButton.setTitle(Constants.LoginScreen.letsGoButton, for: .normal)
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textFieldDidChange(userNameTextField)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty, text != "@" {
            letsGoButton.isUserInteractionEnabled = true
            letsGoButton.backgroundColor = AppColors.mainRed
        } else {
            letsGoButton.isUserInteractionEnabled = false
            letsGoButton.backgroundColor = .systemGray5
        }
    }
}

extension LoginSceneView: LoginSceneProtocol {
    func showAlert(error: String?) {
        AlertManager.shared.showCommonError(self, message: error)
    }
}
