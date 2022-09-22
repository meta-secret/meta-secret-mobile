//
//  AddSecretSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import UIKit

class AddSecretSceneView: UIViewController, AddSecretProtocol, Signable {
    //MARK: - OUTLETS
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
    }
    
    private var viewModel: AddSecretViewModel? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = AddSecretViewModel(delegate: self)
        setupUI()
    }

    //MARK: - ACTIONS
    @IBAction func splitPressed(_ sender: Any) {
        showLoader()
        
        viewModel?.getVault(completion: { [weak self] isEnoughMembers in
            if isEnoughMembers {
                self?.viewModel?.split(secret: self?.passwordTextField.text ?? "", note: self?.noteTextField.text ?? "")
            } else {
                let model = AlertModel(title: Constants.Errors.warning, message: Constants.Errors.notEnoughtMembers)
                self?.showCommonAlert(model)
            }
        })
    }
    
}

private extension AddSecretSceneView {
    //MARK: - UI SETUP
    func setupUI() {
        
        // Title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        self.title = Constants.AddSecret.title
        
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainOrange
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        noteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let pass = passwordTextField.text, !pass.isEmpty, let note = noteTextField.text, !note.isEmpty {
            splitButton.isUserInteractionEnabled = true
            splitButton.backgroundColor = AppColors.mainOrange
        } else {
            splitButton.isUserInteractionEnabled = false
            splitButton.backgroundColor = .systemGray5
        }
    }
}
