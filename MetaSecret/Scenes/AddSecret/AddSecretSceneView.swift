//
//  AddSecretSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import UIKit

class AddSecretSceneView: UIViewController, AddSecretProtocol, Signable, DataSendable {
    //MARK: - OUTLETS
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var addPassTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var addDescriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
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
    private var modeType: ModeType = .edit
    
    private var descriptionText: String? = nil
    
    var dataSent: Any?
    
    //MARK: - LIFE CICLE
    init(modeType: ModeType = .edit) {
        super.init(nibName: "AddSecretSceneView", bundle: nil)
        self.modeType = modeType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        self.viewModel = AddSecretViewModel(delegate: self)
        setupUI()
    }

    //MARK: - ACTIONS
    @IBAction func splitPressed(_ sender: Any) {
        showLoader()
        hideKeyboard()
        isSplitPressed = true
        
        if modeType == .readOnly {
            viewModel?.getVault(completion: { [weak self] isEnoughMembers in
                if isEnoughMembers {
                    self?.viewModel?.restoreSecret(completion: { [weak self] restoredSecret in
                        self?.passwordTextField.text = restoredSecret
                    })
                } else {
                    let secret = self?.viewModel?.readMySecret(description: self?.descriptionTextField.text ?? "")
                    self?.passwordTextField.text = secret
                }
                self?.splitButton.isUserInteractionEnabled = false
                self?.splitButton.backgroundColor = .systemGray5
                self?.hideLoader()
            })
        } else if modeType == .edit {
            viewModel?.getVault(completion: { [weak self] isEnoughMembers in
                if isEnoughMembers {
                    self?.split()
                } else {
                    self?.saveMySecret()
                }
            })
        }
    }
    
    @IBAction func selectThirdTapped(_ sender: Any) {
        viewModel?.showDeviceLists(callBack: { [weak self] isSuccess in
            if isSuccess {
                self?.showCommonAlert(AlertModel(title: Constants.AddSecret.success, message: Constants.AddSecret.successSplited))
            } else {
                self?.saveMySecret()
            }
        })
    }
    
    //MARK: - AddSecretProtocol
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension AddSecretSceneView {
    //MARK: - UI SETUP
    func setupUI() {
        setupNavBar()
        
        //TapGR
        let globalTapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(globalTapGR)
        
        switchMode()
        
        // Texts
        addDescriptionTitle.text = Constants.AddSecret.addDescriptionTitle
        addPassTitleLabel.text = Constants.AddSecret.addPassword
        
        
        instructionLabel.text = Constants.AddSecret.splitInstruction
        selectThirdLabel.text = Constants.AddSecret.selectDevice
        selectThirdButton.setTitle(Constants.AddSecret.selectDeviceButton, for: .normal)
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupData() {
        guard let dataSent = dataSent as? SceneSendDataModel else {
            showCommonError(nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.modeType = dataSent.modeType ?? .edit
        self.descriptionText = dataSent.mainStringValue
    }
    
    func setupNavBar() {
        // Title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        switch modeType {
        case .readOnly:
            self.title = Constants.AddSecret.titleEdit
        case .edit, .distribute:
            self.title = Constants.AddSecret.title
        }
        
        // Back button
        navigationController?.navigationBar.tintColor = AppColors.mainOrange
        navigationItem.hidesBackButton = true
        let chevronLeft = AppImages.chevroneLeft
        let newBackButton = UIBarButtonItem(image: chevronLeft, style: .plain, target: self, action: #selector(backPressed))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        // Right button
        if modeType == .readOnly {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.AddSecret.edit, style: .plain, target: self, action: #selector(editPressed))
            navigationItem.rightBarButtonItem?.tintColor = AppColors.mainOrange
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func split() {
        viewModel?.split(secret: passwordTextField.text ?? "", description: descriptionTextField.text ?? "", callBack: { [weak self] isSuccess in
            if isSuccess {
                self?.hideLoader()
                
                self?.isLocalySaved = false
                
                self?.modeType = .distribute
                self?.switchMode()
            }
        })
    }
    
    func saveMySecret() {
        viewModel?.saveMySecret(part: passwordTextField.text ?? "", description: descriptionTextField.text ?? "", isSplited: false, callBack: { [weak self] in
            
            self?.isLocalySaved = true
            self?.resetScreen()
            self?.hideLoader()
            
            let model = AlertModel(title: Constants.Errors.warning, message: Constants.Errors.notEnoughtMembers)
            self?.showCommonAlert(model)
        })
    }
    
    func resetScreen() {
        passwordTextField.text = ""
        descriptionTextField.text = ""
    }
    
    func switchMode() {
        switch self.modeType {
        case .readOnly:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            descriptionTextField.text = self.descriptionText
            
            passwordTextField.isUserInteractionEnabled = false
            passwordTextField.isEnabled = false
            passwordTextField.text = nil
            passwordTextField.placeholder = Constants.AddSecret.password
            
            splitButton.setTitle(Constants.AddSecret.restore, for: .normal)
            splitButton.isUserInteractionEnabled = true
            splitButton.backgroundColor = AppColors.mainOrange
            
            instructionLabel.isHidden = true
            selectThirdLabel.isHidden = true
            selectThirdButton.isHidden = true
        case .edit:
            descriptionTextField.isUserInteractionEnabled = true
            descriptionTextField.isEnabled = true
            descriptionTextField.placeholder = Constants.AddSecret.description
            descriptionTextField.text = self.descriptionText
            
            passwordTextField.isUserInteractionEnabled = true
            passwordTextField.isEnabled = true
            passwordTextField.placeholder = Constants.AddSecret.password
            
            splitButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitButton.isUserInteractionEnabled = false
            splitButton.backgroundColor = .systemGray5
            
            instructionLabel.isHidden = true
            selectThirdLabel.isHidden = false
            selectThirdButton.isHidden = false
            selectThirdButton.isUserInteractionEnabled = false
            selectThirdButton.backgroundColor = .systemGray5
        case .distribute:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            
            passwordTextField.isUserInteractionEnabled = false
            passwordTextField.isEnabled = false
            
            splitButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitButton.isUserInteractionEnabled = false
            splitButton.backgroundColor = .systemGray5
            
            instructionLabel.isHidden = false
            selectThirdLabel.isHidden = false
            selectThirdButton.isHidden = false
            selectThirdButton.isUserInteractionEnabled = true
            selectThirdButton.backgroundColor = AppColors.mainOrange
        }
    }
    
    @objc func hideKeyboard() {
        passwordTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    @objc func editPressed() {
        modeType = .edit
        switchMode()
    }
    
    @objc func backPressed() {
        if !isSplitPressed || isLocalySaved || isFulySplited || modeType == .readOnly {
            self.navigationController?.popViewController(animated: true)
        } else {
            let warningModel = AlertModel(title: Constants.Errors.warning, message: Constants.AddSecret.notSplitedMessage, okHandler: { [weak self] in
                self?.viewModel?.saveMySecret(part: self?.passwordTextField.text ?? "", description: self?.descriptionTextField.text ?? "", isSplited: false, callBack: { [weak self] in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.animationTime) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            })
            showCommonAlert(warningModel)
        }
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        instructionLabel.isHidden = true
        if let pass = passwordTextField.text, !pass.isEmpty, let note = descriptionTextField.text, !note.isEmpty {
            splitButton.isUserInteractionEnabled = true
            splitButton.backgroundColor = AppColors.mainOrange
        } else {
            splitButton.isUserInteractionEnabled = false
            splitButton.backgroundColor = .systemGray5
        }
    }
}

enum ModeType {
    case readOnly
    case edit
    case distribute
}
