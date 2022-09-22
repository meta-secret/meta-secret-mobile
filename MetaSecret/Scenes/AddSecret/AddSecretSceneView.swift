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
    @IBOutlet weak var addDescriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addPassTitleLabel: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var selectSecondLabel: UILabel!
    @IBOutlet weak var selectSecondButton: UIButton!
    @IBOutlet weak var selectThirdLabel: UILabel!
    @IBOutlet weak var selectThirdButton: UIButton!
    
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
                self?.selectSecondButton.isUserInteractionEnabled = true
                self?.selectSecondButton.backgroundColor = AppColors.mainOrange
                
                self?.selectThirdButton.isUserInteractionEnabled = true
                self?.selectThirdButton.backgroundColor = AppColors.mainOrange
                
                self?.viewModel?.split(secret: self?.passwordTextField.text ?? "", description: self?.noteTextField.text ?? "")
            } else {
                let model = AlertModel(title: Constants.Errors.warning, message: Constants.Errors.notEnoughtMembers)
                self?.showCommonAlert(model)
                self?.viewModel?.saveMySecret(part: self?.passwordTextField.text ?? "", description: self?.noteTextField.text ?? "", callBack: { [weak self] in
                        break
                })
            }
        })
    }
    
    @IBAction func selectSecondTapped(_ sender: Any) {
    }
    
    @IBAction func selectThirdTapped(_ sender: Any) {
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
        
        // Buttons
        selectSecondButton.isUserInteractionEnabled = false
        selectSecondButton.backgroundColor = .systemGray5
        
        selectThirdButton.isUserInteractionEnabled = false
        selectThirdButton.backgroundColor = .systemGray5
        
        // Texts
        addDescriptionTitle.text = Constants.AddSecret.addDescriptionTitle
        addPassTitleLabel.text = Constants.AddSecret.addPassword
        passwordTextField.placeholder = Constants.AddSecret.password
        noteTextField.placeholder = Constants.AddSecret.description
        
        instructionLabel.text = Constants.AddSecret.splitInstruction
        selectSecondLabel.text = Constants.AddSecret.selectSecond
        selectThirdLabel.text = Constants.AddSecret.selectThird
        selectSecondButton.setTitle(Constants.AddSecret.selectSecondButton, for: .normal)
        selectThirdButton.setTitle(Constants.AddSecret.selectThirdButton, for: .normal)
        
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
