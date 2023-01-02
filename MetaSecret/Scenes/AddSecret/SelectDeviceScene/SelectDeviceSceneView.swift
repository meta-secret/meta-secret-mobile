//
//  SelectDeviceSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 07.09.2022.
//

import UIKit

class SelectDeviceSceneView: CommonSceneView{
    
    private struct Config {
        static let cellID = "ClusterDeviceCell"
        static let cellHeight: CGFloat = 60
        static let devicesCountToDistribute = 2
    }
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var distributeButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    //MARK: - PROPERTIES
    var viewModel: DeviceInfoSceneViewModel
    var model: SceneSendDataModel? = nil
    override var commonViewModel: CommonViewModel {
        return viewModel
    }
    private var source = [UserSignature]()
    private var shares: [String]? = nil
    private var note: String? = nil
    private var callback: ((Bool)->())? = nil
    private var selectedCellIndexes: [IndexPath] = [IndexPath]()

    //MARK: - LIFE CICLE
    init(viewModel: DeviceInfoSceneViewModel, alertManager: Alertable) {
        self.viewModel = viewModel
        super.init(alertManager: alertManager)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shares = model?.stringArray
        note = model?.mainStringValue
        callback = model?.callBack
        
        checkButtonAvailability()
    }
    
    override func setupUI() {
        internalSetupUI()
    }
    
    //MARK: - DATA RELOAD
    func reloadData(source: [UserSignature]) {
        self.source = source
        if !source.isEmpty {
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func distributeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
        callback?(true)
    }
}

//MARK: - TABLE VIEW DELEGATE DATA SOURCE
extension SelectDeviceSceneView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Config.cellID, for: indexPath) as! ClusterDeviceCell
        
        let cellSource = CellSetupDate()
        let member = source[indexPath.row]
        
        let isSelected = selectedCellIndexes.contains(where: {$0 == indexPath})
        
        cellSource.setupCellSource(title: member.device.deviceName, subtitle: member.device.deviceId, boolValue: isSelected, imageName: AppImages.doneCheckmark )
        
        cell.setupCell(content: cellSource)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedItemIndex = selectedCellIndexes.firstIndex(where: {$0 == indexPath}) {
            selectedCellIndexes.remove(at: selectedItemIndex)
            tableView.reloadData()
            checkButtonAvailability()
            return
        }
        
        if selectedCellIndexes.count >= Config.devicesCountToDistribute {
            selectedCellIndexes.removeFirst()
        }
        
        selectedCellIndexes.append(indexPath)
        tableView.reloadData()
        
        checkButtonAvailability()
    }
}

//MARK: - PRIVATE FUNCS
private extension SelectDeviceSceneView {
    func internalSetupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: Config.cellID, bundle: nil), forCellReuseIdentifier: Config.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Config.cellHeight
        tableView.contentInset.top = .zero
        tableView.delegate = self
        tableView.dataSource = self
        
        instructionLabel.text = Constants.SelectDevice.chooseDevices
    }
    
    func checkButtonAvailability() {
        if selectedCellIndexes.count < Config.devicesCountToDistribute {
            distributeButton.isUserInteractionEnabled = false
            distributeButton.backgroundColor = .systemGray5
        } else {
            distributeButton.isUserInteractionEnabled = true
            distributeButton.backgroundColor = AppColors.mainOrange
        }
    }
}
