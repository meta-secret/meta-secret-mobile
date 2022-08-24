//
//  MainSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 22.08.2022.
//

import UIKit

class MainSceneView: UIViewController, MainSceneProtocol {
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - PROPERTIES
    private var viewModel: MainSceneViewModel? = nil
    fileprivate var pendings: [Vault] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel = MainSceneViewModel(delegate: self)
    }

    func reloadData(pendings: [Vault]) {
        self.pendings = pendings
        tableView.reloadData()
    }
}

private extension MainSceneView {
    func setupUI() {
        self.title = Constants.LoginScreen.title
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClusterDeviceCell", bundle: nil), forCellReuseIdentifier: "ClusterDeviceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        setupNavBar()
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    @objc func addTapped() {
        
    }
}


extension MainSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClusterDeviceCell", for: indexPath) as! ClusterDeviceCell
        cell.setupCell(vault: pendings[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendings.count
    }
}
