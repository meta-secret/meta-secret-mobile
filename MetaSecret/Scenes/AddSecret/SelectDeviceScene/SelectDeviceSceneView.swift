//
//  SelectDeviceSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import UIKit

class SelectDeviceSceneView: UIViewController, DataSendable, SelectDeviceProtocol, Loaderable, Alertable {
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - PROPERTIES
    private var viewModel: SelectDeviceViewModel? = nil
    private var source = [Vault]()
    private var shares = [String]()
    private var note = ""
    
    var dataSent: Any? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        showLoader()
        self.viewModel = SelectDeviceViewModel(delegate: self)
    }
    
    func reloadData(source: [Vault]) {
        self.source = source
        if !source.isEmpty {
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
        hideLoader()
    }

}

extension SelectDeviceSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClusterDeviceCell", for: indexPath) as! ClusterDeviceCell
        
        let cellSource = CellSetupDate()
        let member = source[indexPath.row]
        cellSource.setupCellSource(title: member.device?.deviceName ?? "", subtitle: member.device?.deviceId ?? "")
        
        cell.setupCell(content: cellSource)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showLoader()
        let member = source[indexPath.row]
        guard let share = shares.first else {
            showCommonError(nil)
            return
        }
        
        viewModel?.send(share, to: member, with: note )
        source.removeFirst()
        
        if source.isEmpty {
            self.dismiss(animated: true)
        }
    }
}

private extension SelectDeviceSceneView {
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClusterDeviceCell", bundle: nil), forCellReuseIdentifier: "ClusterDeviceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
}
