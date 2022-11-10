//
//  MainSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

class MainSceneView: UIViewController, MainSceneProtocol, Routerable, Loaderable, UD {
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
    
    //MARK: - PROPERTIES
    private var viewModel: MainSceneViewModel? = nil
    private var selectedSegment: MainScreenSourceType = .Secrets
    private var source: MainScreenSource? = nil
    private var currentTab: Int = 0
    
    private struct Config {
        static let cellID = "ClusterDeviceCell"
        static let cellHeight: CGFloat = 60
        static let titleSize: CGFloat = 18
        static let minDevicesCount = 3
    }

    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel = MainSceneViewModel(delegate: self)
        showLoader()
        viewModel?.getAllSecrets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch selectedSegment {
        case .Secrets:
            viewModel?.getAllSecrets()
        case .Devices:
            viewModel?.getVault()
        case .None:
            break
        }
    }

    //MARK: - VM DELEGATION
    func reloadData(source: MainScreenSource?) {
        hideLoader()
        if (source?.items.isEmpty ?? true ) && selectedSegment == .Secrets && isFirstAppLaunch {
            isFirstAppLaunch = false
            selectedSegment = .Devices
            selectTab(index: selectedSegment.rawValue)
            if shouldShowVirtualHint && isOwner {
                showFirstTimePopupHint()
            }
            return
        }
        
        self.source = source
        if !(source?.items.isEmpty ?? true) {
            tableView.isHidden = false
            tableView.reloadData()
            
            let flatArr = source?.items.flatMap { $0 }
            let filteredArr = flatArr?.filter({$0.subtitle?.lowercased() == VaultInfoStatus.member.rawValue})
            
            guard filteredArr?.count ?? 0 < Config.minDevicesCount else { return }
            
            remainigLabel.text = Constants.MainScreen.addDevices(memberCounts: filteredArr?.count ?? 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Common.waitingTime) { [weak self] in
                guard let `self` = self else { return }
                
                if (self.selectedSegment == .Secrets) || (!self.isOwner) {
                    self.remainingNotificationContainer.isHidden = true
                } else {
                    self.remainingNotificationContainer.isHidden = false
                }
                
                self.remainingNotification.showShadow()
            }
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    //MARK: - IBACTIONS
    @IBAction func selectorPressed(_ sender: UISegmentedControl) {
        remainingNotificationContainer.isHidden = true
        currentTab = sender.selectedSegmentIndex
        selectTab(index: currentTab)
    }
    
}

//MARK: - PRIVATE METHODS
private extension MainSceneView {
    //MARK: - SETUP UI
    func setupUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        
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
        
        setTitle()
        yourDevicesTitleLabel.text = Constants.MainScreen.yourSecrets
        nickNameTitleLabel.text = Constants.MainScreen.yourNick
        nickNameLabel.text = mainUser?.vaultName
    }
    
    func setTitle() {
        emptyLabel.text = selectedSegment.rawValue == 0 ? Constants.MainScreen.noSecrets : ""
        self.title = selectedSegment.rawValue == 0 ? Constants.MainScreen.secrets : Constants.MainScreen.devices
    }
    
    //MARK: - TAB SELECTING
    func selectTab(index: Int) {
        selector.selectedSegmentIndex = index
        reloadData(source: nil)
        
        selectedSegment = MainScreenSourceType(rawValue: index) ?? .None
        
        let flatArr = source?.items.flatMap { $0 }
        let filteredArr = flatArr?.filter({$0.subtitle == VaultInfoStatus.member.rawValue})
        addDeviceView.isHidden = (selectedSegment == .Devices && (filteredArr?.count ?? 0 > Config.minDevicesCount))
        
        yourDevicesTitleLabel.text = selectedSegment == .Secrets ? Constants.MainScreen.yourSecrets : Constants.MainScreen.yourDevices
        
        setTitle()
        viewModel?.getNewDataSource(type: selectedSegment)
    }
    
    //MARK: - ROUTING
    @objc func remainigLabelTapped() {
        showFirstTimePopupHint()
    }
    
    @objc func addDeviceTapped() {
        if selectedSegment == .Devices {
            let model = BottomInfoSheetModel(title: Constants.Devices.istallInstructionTitle, message: Constants.Devices.istallInstruction(name: mainUser?.vaultName ?? ""), isClosable: true)
            routeTo(.popupHint, presentAs: .presentFullScreen, with: model)
        } else {
            let model = SceneSendDataModel(modeType: .edit)
            routeTo(.split, presentAs: .push, with: model)
        }
    }
    
    //MARK: - HINTS
    func showFirstTimePopupHint() {
        let model = BottomInfoSheetModel(title: Constants.MainScreen.titleFirstTimeHint, message: Constants.MainScreen.messageFirstTimeHint(name: mainUser?.vaultName ?? ""), buttonHandler: { [weak self] in

            self?.shouldShowVirtualHint = false
            if self?.additionalUsers.isEmpty ?? true {
                self?.viewModel?.generateVirtualVaults()
            }
        })
        routeTo(.popupHint, presentAs: .presentFullScreen, with: model)
    }
}

//MARK: - TABLE VIEW DELEGATE DATA SOURCE
extension MainSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Config.cellID, for: indexPath) as! ClusterDeviceCell
        guard let content = source?.items[indexPath.section][indexPath.row] else {
            return UITableViewCell()
        }
        
        if selectedSegment == .Secrets {
            content.imageName = AppImages.warningSymbol
        }
        
        cell.setupCell(content: content)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.items[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return source?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let content = source?.items[indexPath.section][indexPath.row] else {
            return
        }
        
        if selectedSegment == .Devices, content.boolValue {
            let flattenArray = (viewModel?.vault?.declinedJoins ?? []) + (viewModel?.vault?.pendingJoins ?? []) + (viewModel?.vault?.signatures ?? [])
            let selectedVault = flattenArray.first(where: {$0.device?.deviceId == content.id })
            
            let model = SceneSendDataModel(vault: selectedVault) { [weak self] isSuccess in
                #warning("Need to send data from virtual to real")
                self?.additionalUsers.removeFirst()
                self?.viewModel?.getVault()
            }
            routeTo(.deviceInfo, presentAs: .push, with: model)
        } else if selectedSegment == .Secrets {
            let model = SceneSendDataModel(mainStringValue: content.title, modeType: .readOnly)
            routeTo(.split, presentAs: .push, with: model)
        }
    }
}
