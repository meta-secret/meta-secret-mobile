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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel = MainSceneViewModel(delegate: self)
//        selectTab(index: MainScreenSourceType.Vaults.rawValue)
    }

    func reloadData(source: MainScreenSource) {
        self.source = source
        if !source.items.isEmpty {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    @IBAction func selectorPressed(_ sender: UISegmentedControl) {
        selectTab(index: sender.numberOfSegments - 1)
    }
    
}

private extension MainSceneView {
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClusterDeviceCell", bundle: nil), forCellReuseIdentifier: "ClusterDeviceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        setupNavBar()
        selectTab(index: 0)
    }
    
    func selectTab(index: Int) {
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
        guard let items = source?.items else { return UITableViewCell()}
        cell.setupCell(content: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.items.count ?? 0
    }
}
