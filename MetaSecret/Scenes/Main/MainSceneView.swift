//
//  MainSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

class MainSceneView: UIViewController, MainSceneProtocol, Routerable {
    //MARK: - OUTLETS
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - PROPERTIES
    private var viewModel: MainSceneViewModel? = nil
    private var selectedSegment: MainScreenSourceType = .Vaults
    private var source: MainScreenSource? = nil
    private var currentTab: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel = MainSceneViewModel(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectTab(index: currentTab)
    }

    func reloadData(source: MainScreenSource?) {
        self.source = source
        if !(source?.items.isEmpty ?? true) {
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func selectorPressed(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        selectTab(index: currentTab)
    }
    
}

private extension MainSceneView {
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClusterDeviceCell", bundle: nil), forCellReuseIdentifier: "ClusterDeviceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    func selectTab(index: Int) {
        reloadData(source: nil)
        
        if index == 0 {
            setupNavBar()
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        selectedSegment = MainScreenSourceType(rawValue: index) ?? .None
        setTitle()
        
        viewModel?.getNewDataSource(type: selectedSegment)
    }
    
    func setTitle() {
        self.title = selectedSegment.rawValue == 0 ? Constants.MainScreen.secrets : Constants.MainScreen.devices
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        routeTo(.split, presentAs: .push)
    }
}


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
        headerView.backgroundColor = .lightGray
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return source?.items[section].isEmpty ?? true ? 0 : 33
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
