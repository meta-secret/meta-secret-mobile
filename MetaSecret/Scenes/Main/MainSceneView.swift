//
//  MainSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit
import PromiseKit

class MainSceneView: CommonSceneView, MainSceneProtocol {
    //MARK: - OUTLETS
    @IBOutlet weak var deviceNameContainer: UIView!
    @IBOutlet weak var nickNameTitleLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var addDeviceView: UIView!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remainingNotificationContainer: UIView!
    @IBOutlet weak var remainingNotification: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var remainigLabel: UILabel!
    @IBOutlet weak var yourDevicesTitleLabel: UILabel!
    @IBOutlet weak var newBubble: UIView!
    
    //MARK: - PROPERTIES
    var viewModel: MainSceneViewModel
    override var commonViewModel: CommonViewModel {
        return viewModel
    }

    private var userService: UsersServiceProtocol
    private var factory: UIFactoryProtocol
    
    private struct Config {
        static let cellID = "ClusterDeviceCell"
        static let cellHeight: CGFloat = 60
        static let titleSize: CGFloat = 18
    }

    //MARK: - LIFECYCLE
    init(viewModel: MainSceneViewModel, alertManager: Alertable, factory: UIFactoryProtocol, userService: UsersServiceProtocol) {
        self.userService = userService
        self.viewModel = viewModel
        self.factory = factory
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchCallback(_:)), name: NSNotification.Name(rawValue: "distributionService"), object: nil)
    }
    
    override func setupUI() {
        internalSetupUI()
    }
    
    override func updateUI() {
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - IBACTIONS
    @IBAction func selectorPressed(_ sender: UISegmentedControl) {
        remainingNotificationContainer.isHidden = true
        viewModel.selectedSegment = MainScreenSourceType(rawValue: sender.selectedSegmentIndex) ?? .Secrets
        selectTab()
    }
    
}

//MARK: - PRIVATE METHODS
private extension MainSceneView {
    //MARK: - SETUP UI
    func internalSetupUI() {
        super.setupUI()
        
        selector.setTitle(Constants.MainScreen.secrets, forSegmentAt: 0)
        selector.setTitle(Constants.MainScreen.devices, forSegmentAt: 1)
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: Config.cellID, bundle: nil), forCellReuseIdentifier: Config.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Config.cellHeight
        tableView.contentInset.top = .zero
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addDeviceTapped))
        addDeviceView.addGestureRecognizer(tapGR)
        
        let labelTapGR = UITapGestureRecognizer(target: self, action: #selector(remainigLabelTapped))
        remainingNotification.addGestureRecognizer(labelTapGR)
        
        setEmptyStatus()
        yourDevicesTitleLabel.text = Constants.MainScreen.yourSecrets
        nickNameTitleLabel.text = Constants.MainScreen.yourNick
        nickNameLabel.text = userService.userSignature?.vaultName
        
        newBubble.layer.cornerRadius = 10.0
        newBubble.isHidden = true
    }
    
    func reloadData() {
        /// ONLY for first launch
        if (viewModel.source?.items.isEmpty ?? true ) && viewModel.selectedSegment == .Secrets && userService.isFirstAppLaunch {
            userService.isFirstAppLaunch = false
            viewModel.selectedSegment = .Devices
            selectTab()
            if userService.shouldShowVirtualHint && userService.isOwner {
                remainigLabelTapped()
            }
            return
        }
        
        if !(viewModel.source?.items.isEmpty ?? true) {
            tableView.isHidden = false
            tableView.reloadData()
            
            remainigLabel.text = viewModel.remainingDevicesText
            self.remainingNotificationContainer.isHidden = viewModel.remainingNotificationContainerHidden
            self.remainingNotification.showShadow()
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    func setEmptyStatus() {
        emptyLabel.text = viewModel.emptyStatusText
    }
    
    //MARK: - CALL BACK FROM DISTRIBUTION SERVICE
    @objc func switchCallback(_ notification: NSNotification) {
        if let type = notification.userInfo?["type"] as? CallBackType {
            switch type {
            case .Shares:
                if viewModel.selectedSegment == .Secrets {
                    firstly {
                        viewModel.getAllLocalSecrets()
                    }.catch { e in
                        let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
                        self.alertManager.showCommonError(text)
                        self.viewModel.isToReDistribute = false
                    }.finally {
                        if self.viewModel.isToReDistribute {
                            self.viewModel.isToReDistribute = false
                            self.reDistribue()
                        } else {
                            self.reloadData()
                        }
                    }
                }
            case .Devices:
                newBubble.isHidden = userService.mainVault?.pendingJoins?.count == 0
                if viewModel.selectedSegment == .Devices {
                    firstly {
                        viewModel.getLocalVaultMembers()
                    }.catch { e in
                        let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
                        self.alertManager.showCommonError(text)
                        self.viewModel.isToReDistribute = false
                    }.finally {
                        if self.viewModel.isToReDistribute {
                            self.viewModel.isToReDistribute = false
                            self.reDistribue()
                        } else {
                            self.reloadData()
                        }
                    }
                }
            case .Claims(_):
                break
            case .Failure:
                viewModel.isToReDistribute = false
                break
            }
        }
    }
    
    func reDistribue() {
        firstly {
            viewModel.reDistribue()
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.hideLoader()
            self.alertManager.showCommonError(text)
        }.finally {
            self.alertManager.hideLoader()
            self.viewModel.isToReDistribute = false
            self.reloadData()
        }
    }
    
    //MARK: - TAB SELECTING
    func selectTab() {
        let index = viewModel.selectedSegment.rawValue
        selector.selectedSegmentIndex = index
        addDeviceView.isHidden = viewModel.addDeviceViewHidden
        yourDevicesTitleLabel.text = viewModel.yourDeviceTitle
        setEmptyStatus()
        setAttributedTitle(viewModel.title)
        
        firstly {
            viewModel.getNewDataSource()
        }.catch { e in
            let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
            self.alertManager.showCommonError(text)
        }.finally {
            self.reloadData()
        }
    }
    
    //MARK: - ROUTING
    @objc func remainigLabelTapped() {
        let model = BottomInfoSheetModel(title: Constants.MainScreen.titleFirstTimeHint,
                                         message: Constants.MainScreen.messageFirstTimeHint(name: userService.userSignature?.vaultName ?? ""), buttonHandler: { [weak self] in
            self?.userService.shouldShowVirtualHint = false
        })
        let controller = factory.popUpHint(with: model)
        popUp(controller)
    }
    
    @objc func addDeviceTapped() {
        if viewModel.selectedSegment == .Devices {
            let model = BottomInfoSheetModel(title: Constants.Devices.istallInstructionTitle, message: Constants.Devices.installInstruction(name: userService.userSignature?.vaultName ?? ""), isClosable: true)
            let controller = factory.popUpHint(with: model)
            popUp(controller)
        } else {
            let model = SceneSendDataModel(modeType: .edit)
            let controller = factory.split(model: model)
            push(controller)
        }
    }
}

//MARK: - TABLE VIEW DELEGATE DATA SOURCE
extension MainSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Config.cellID, for: indexPath) as! ClusterDeviceCell
        guard indexPath.section < viewModel.source?.items.count ?? 0,
              indexPath.row < viewModel.source?.items[indexPath.section].count ?? 0,
              let content = viewModel.source?.items[indexPath.section][indexPath.row] else {
            return UITableViewCell()
        }
        
        if viewModel.selectedSegment == .Secrets {
            content.imageName = AppImages.warningSymbol
        }
        
        cell.setupCell(content: content)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.source?.items[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.source?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let content = viewModel.source?.items[indexPath.section][indexPath.row] else {
            return
        }
        
        if viewModel.selectedSegment == .Devices, content.boolValue {
            let selectedItem = viewModel.selectedDevice(content: content)
            let model = SceneSendDataModel(signature: selectedItem, callBack:  { [weak self] isOk in
                guard let self else { return }
                if isOk {
                    self.alertManager.showLoader()
                    self.viewModel.isToReDistribute = true
                }
                
                firstly {
                    self.viewModel.getVault()
                }.catch { e in
                    let text = (e as? MetaSecretErrorType)?.message() ?? e.localizedDescription
                    self.alertManager.showCommonError(text)
                }.finally {
                    self.reloadData()
                }
            })
            
            let controller = factory.deviceInfo(model: model)
            push(controller)
            
        } else if viewModel.selectedSegment == .Secrets {
            let model = SceneSendDataModel(mainStringValue: content.title, modeType: .readOnly)
            let controller = factory.split(model: model)
            push(controller)
        }
    }
}

extension MainSceneView: ClusterDeviceCellDelegate {
    func buttonTapped() {
        alertManager.showCommonAlert(AlertModel(title: Constants.Errors.warning, message: Constants.MainScreen.notBackedUp, cancelButton: nil))
    }
}
