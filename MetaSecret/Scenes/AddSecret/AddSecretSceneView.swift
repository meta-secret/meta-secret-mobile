//
//  AddSecretSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 25.08.2022.
//

import UIKit

class AddSecretSceneView: UIViewController, AddSecretProtocol, Signable, DataSendable {
    //MARK: - OUTLETS
    @IBOutlet weak var splitRestoreButton: UIButton!
    @IBOutlet weak var addPassTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var addDescriptionTitle: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var selectSaveInfoLabel: UILabel!
    @IBOutlet weak var selectSaveButton: UIButton!
    
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
        showLoader()
        self.viewModel = AddSecretViewModel(delegate: self)
        viewModel?.getVault(completion: { [weak self] in
            self?.hideLoader()
        })
        setupUI()
    }
    
    //MARK: - ACTIONS
    @IBAction func splitRestoreButtonPressed(_ sender: Any) {
        showLoader()
        hideKeyboard()
        isSplitPressed = true

        if modeType == .readOnly {
            restore()
        } else if modeType == .edit {
            split()
        }
    }
    
    @IBAction func selectSaveButtonTapped(_ sender: Any) {
        if (viewModel?.vaultsCount() ?? 1) <= Constants.Common.neededMembersCount {
            viewModel?.encryptAndDistribute(callBack: { [weak self] isSuccess in
                self?.hideLoader()
                
                if isSuccess {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showCommonError(MetaSecretErrorType.distribute.message())
                    self?.resetScreen()
                }
            })
        } else {
            showLoader()
            viewModel?.showDeviceLists(callBack: { [weak self] isSuccess in
                self?.hideLoader()
                if isSuccess {
                    self?.showCommonAlert(AlertModel(title: Constants.AddSecret.success, message: Constants.AddSecret.successSplited, okButton: Constants.Alert.ok, okHandler: { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                } else {
                    self?.showCommonError(MetaSecretErrorType.distribute.message())
                    self?.resetScreen()
                }
            })
        }
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
        
        
        selectSaveInfoLabel.text = Constants.AddSecret.selectDevice
        selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButton, for: .normal)
        
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
                
                self?.modeType = .distribute
                self?.switchMode()
            } else {
                self?.hideLoader()
                self?.showCommonError(nil)
                self?.resetScreen()
                self?.switchMode()
            }
        })
    }
    
    func restore() {
        viewModel?.restoreSecret(descriptionTextField.text ?? "", callBack: { [weak self] restoredSecret in
            
            guard let restoredSecret else {
                self?.showCommonError(MetaSecretErrorType.restore.message())
                return
            }
            
            self?.passwordTextField.text = restoredSecret
            
            self?.splitRestoreButton.isUserInteractionEnabled = false
            self?.splitRestoreButton.backgroundColor = .systemGray5
            self?.hideLoader()
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
            
            splitRestoreButton.setTitle(Constants.AddSecret.restore, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = true
            splitRestoreButton.backgroundColor = AppColors.mainOrange
            
            instructionLabel.isHidden = true
            selectSaveInfoLabel.isHidden = true
            selectSaveButton.isHidden = true
        case .edit:
            descriptionTextField.isUserInteractionEnabled = true
            descriptionTextField.isEnabled = true
            descriptionTextField.placeholder = Constants.AddSecret.description
            descriptionTextField.text = self.descriptionText
            
            passwordTextField.isUserInteractionEnabled = true
            passwordTextField.isEnabled = true
            passwordTextField.placeholder = Constants.AddSecret.password
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            
            instructionLabel.isHidden = true
            selectSaveInfoLabel.isHidden = false
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = false
            selectSaveButton.backgroundColor = .systemGray5
        case .distribute:
            descriptionTextField.isUserInteractionEnabled = false
            descriptionTextField.isEnabled = false
            
            passwordTextField.isUserInteractionEnabled = false
            passwordTextField.isEnabled = false
            
            splitRestoreButton.setTitle(Constants.AddSecret.split, for: .normal)
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
            
            instructionLabel.isHidden = false
            
            selectSaveButton.isHidden = false
            selectSaveButton.isUserInteractionEnabled = true
            selectSaveButton.backgroundColor = AppColors.mainOrange
            if ((viewModel?.vaultsCount() ?? 1) <= Constants.Common.neededMembersCount) {
                selectSaveInfoLabel.isHidden = true
                instructionLabel.isHidden = true
                selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButtonLocal, for: .normal)
            } else {
                selectSaveInfoLabel.isHidden = false
                selectSaveButton.setTitle(Constants.AddSecret.selectDeviceButton, for: .normal)
            }
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
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TEXT FIELD DELEGATE
    @objc func textFieldDidChange(_ textField: UITextField) {
        instructionLabel.isHidden = true
        if let pass = passwordTextField.text, !pass.isEmpty, let note = descriptionTextField.text, !note.isEmpty {
            splitRestoreButton.isUserInteractionEnabled = true
            splitRestoreButton.backgroundColor = AppColors.mainOrange
        } else {
            splitRestoreButton.isUserInteractionEnabled = false
            splitRestoreButton.backgroundColor = .systemGray5
        }
    }
}

enum ModeType {
    case readOnly
    case edit
    case distribute
}
