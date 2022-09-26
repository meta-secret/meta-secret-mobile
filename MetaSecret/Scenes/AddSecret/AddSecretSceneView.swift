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
    @IBOutlet weak var selectThirdLabel: UILabel!
    @IBOutlet weak var selectThirdButton: UIButton!
    
    //MARK: - PROPERTIES
    private struct Config {
        static let titleSize: CGFloat = 18
    }
    
    private var viewModel: AddSecretViewModel? = nil
    private var isLocalySaved: Bool = false
    private var isFulySplited: Bool = false
    private var isSplitPressed: Bool = false
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = AddSecretViewModel(delegate: self)
        setupUI()
    }

    //MARK: - ACTIONS
    @IBAction func splitPressed(_ sender: Any) {
        showLoader()
        hideKeyboard()
        isSplitPressed = true
        
        viewModel?.getVault(completion: { [weak self] isEnoughMembers in
            if isEnoughMembers {
                self?.selectThirdButton.isUserInteractionEnabled = true
                self?.selectThirdButton.backgroundColor = AppColors.mainOrange
                
                self?.viewModel?.split(secret: self?.passwordTextField.text ?? "", description: self?.noteTextField.text ?? "", callBack: { [weak self] isSuccess in
                    if isSuccess {
                        self?.hideLoader()
                        
                        self?.isLocalySaved = false
                        
                        self?.splitButton.isUserInteractionEnabled = false
                        self?.splitButton.backgroundColor = .systemGray5
                    }
                })
            } else {
                self?.viewModel?.saveMySecret(part: self?.passwordTextField.text ?? "", description: self?.noteTextField.text ?? "", isSplited: false, callBack: { [weak self] in
                    
                    self?.isLocalySaved = true
                    self?.resetScreen()
                    self?.hideLoader()
                    
                    let model = AlertModel(title: Constants.Errors.warning, message: Constants.Errors.notEnoughtMembers)
                    self?.showCommonAlert(model)
                })
            }
        })
    }
    
    @IBAction func selectThirdTapped(_ sender: Any) {
        viewModel?.showDeviceLists()
    }
    
}

private extension AddSecretSceneView {
    //MARK: - UI SETUP
    func setupUI() {
        //TapGR
        let globalTapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(globalTapGR)
        
        // Title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        self.title = Constants.AddSecret.title
        
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainOrange
        navigationItem.hidesBackButton = true
        let chevronLeft = UIImage(systemName: "chevron.left")
        let newBackButton = UIBarButtonItem(image: chevronLeft, style: .plain, target: self, action: #selector(backPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        // Buttons
        resetScreen()
        
        // Texts
        addDescriptionTitle.text = Constants.AddSecret.addDescriptionTitle
        addPassTitleLabel.text = Constants.AddSecret.addPassword
        passwordTextField.placeholder = Constants.AddSecret.password
        noteTextField.placeholder = Constants.AddSecret.description
        
        instructionLabel.text = Constants.AddSecret.splitInstruction
        selectThirdLabel.text = Constants.AddSecret.selectDevice
        selectThirdButton.setTitle(Constants.AddSecret.selectDeviceButton, for: .normal)
        splitButton.setTitle(Constants.AddSecret.split, for: .normal)
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        noteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func resetScreen() {
        passwordTextField.text = ""
        noteTextField.text = ""
        
        splitButton.isUserInteractionEnabled = false
        splitButton.backgroundColor = .systemGray5

//        selectThirdButton.isUserInteractionEnabled = false
//        selectThirdButton.backgroundColor = .systemGray5
    }
    
    @objc func hideKeyboard() {
        passwordTextField.resignFirstResponder()
        noteTextField.resignFirstResponder()
    }
    
    @objc func backPressed() {
        if !isSplitPressed || isLocalySaved || isFulySplited {
            self.navigationController?.popViewController(animated: true)
        } else {
            let warningModel = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.notSplitedMessage, okHandler: { [weak self] in
                self?.viewModel?.saveMySecret(part: self?.passwordTextField.text ?? "", description: self?.noteTextField.text ?? "", isSplited: false, callBack: { [weak self] in
                    
                    self?.navigationController?.popViewController(animated: true)
                })
            })
            showCommonAlert(warningModel)
        }
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        instructionLabel.isHidden = true
        if let pass = passwordTextField.text, !pass.isEmpty, let note = noteTextField.text, !note.isEmpty {
            splitButton.isUserInteractionEnabled = true
            splitButton.backgroundColor = AppColors.mainOrange
        } else {
            splitButton.isUserInteractionEnabled = false
            splitButton.backgroundColor = .systemGray5
        }
    }
}
