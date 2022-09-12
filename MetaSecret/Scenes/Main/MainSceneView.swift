//
//  MainSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

class MainSceneView: UIViewController, MainSceneProtocol, Routerable, Loaderable, UD {
    //MARK: - OUTLETS
    private struct Config {
        static let cellID = "ClusterDeviceCell"
        static let cellHeight: CGFloat = 60
        static let titleSize: CGFloat = 18
    }
    
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    //MARK: - PROPERTIES
    private var viewModel: MainSceneViewModel? = nil
    private var selectedSegment: MainScreenSourceType = .Secrets
    private var source: MainScreenSource? = nil
    private var currentTab: Int = 0

    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel = MainSceneViewModel(delegate: self)
        viewModel?.getAllSecrets()
    }

    //MARK: - VM DELEGATION
    func reloadData(source: MainScreenSource?) {
        hideLoader()
        if (source?.items.isEmpty ?? true ) && selectedSegment == .Secrets {
            selectedSegment = .Devices
            selectTab(index: selectedSegment.rawValue)
            if shouldShowVirtualHint {
                showFirstTimePopupHint()
            }
            return
        }
        
        self.source = source
        if !(source?.items.isEmpty ?? true) {
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    //MARK: - IBACTIONS
    @IBAction func selectorPressed(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        selectTab(index: currentTab)
    }
    
}

//MARK: - PRIVATE METHODS
private extension MainSceneView {
    //MARK: - SETUP UI
    func setupUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.avenirMedium(size: Config.titleSize)]
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: Config.cellID, bundle: nil), forCellReuseIdentifier: Config.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Config.cellHeight
    }
    
    func setTitle() {
        emptyLabel.text = selectedSegment.rawValue == 0 ? Constants.MainScreen.noSecrets : Constants.MainScreen.noDevices
        self.title = selectedSegment.rawValue == 0 ? Constants.MainScreen.secrets : Constants.MainScreen.devices
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    //MARK: - TAB SELECTING
    func selectTab(index: Int) {
        selector.selectedSegmentIndex = selectedSegment.rawValue
        reloadData(source: nil)
        
        if index == 0 {
//            setupNavBar()
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        selectedSegment = MainScreenSourceType(rawValue: index) ?? .None
        setTitle()
        
        viewModel?.getNewDataSource(type: selectedSegment)
    }
    
    //MARK: - ROUTING
    @objc func addTapped() {
        routeTo(.split, presentAs: .push)
    }
    
    //MARK: - HINTS
    func showFirstTimePopupHint() {
        let model = BottomInfoSheetModel(title: Constants.MainScreen.titleFirstTimeHint, message: Constants.MainScreen.messageFirstTimeHint, buttonHandler: { [weak self] in
            self?.shouldShowVirtualHint = false
            self?.viewModel?.generateVirtualVaults()
        })
        routeTo(.popupHint, presentAs: .presentFullScreen, with: model)
    }
}

//MARK: - TABLE VIEW DELEGATE DATA SOURCE
extension MainSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClusterDeviceCell", for: indexPath) as! ClusterDeviceCell
        guard let content = source?.items[indexPath.section][indexPath.row] else {
            return UITableViewCell()
        }
        cell.setupCell(content: content)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return source?.items[section].isEmpty ?? true ? 0 : 12
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.items[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return source?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let content = source?.items[indexPath.section][indexPath.row], content.boolValue else {
            return
        }
        
        let flattenArray = (viewModel?.vault?.declinedJoins ?? []) + (viewModel?.vault?.pendingJoins ?? []) + (viewModel?.vault?.signatures ?? [])
        let selectedVault = flattenArray.first(where: {$0.device?.deviceId == content.id })

        routeTo(.deviceInfo, presentAs: .push, with: selectedVault)
    }
}
