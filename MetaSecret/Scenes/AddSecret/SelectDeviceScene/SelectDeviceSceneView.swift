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
    private var share: String?
    private var note: String?
    private var callback: (()->())?
    
    var dataSent: Any? = nil
    
    //MARK: - LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = SelectDeviceViewModel(delegate: self)
        guard let model = dataSent as? SceneSendDataModel else { return }
        share = model.stringValue
        note = model.mainStringValue
        callback = model.callBack
    }
    
    //MARK: - DATA RELOAD
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

//MARK: - TABLE VIEW DELEGATE DATA SOURCE
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
        
        let member = source[indexPath.row]
        guard let share = share, let note = note else {
            showCommonError(nil)
            return
        }
        showLoader()
        viewModel?.send(share, to: member, with: note, callback: { [weak self] in
            self?.dismiss(animated: true)
            self?.callback?()
        })
    }
}

//MARK: - PRIVATE FUNCS
private extension SelectDeviceSceneView {
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClusterDeviceCell", bundle: nil), forCellReuseIdentifier: "ClusterDeviceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
}
