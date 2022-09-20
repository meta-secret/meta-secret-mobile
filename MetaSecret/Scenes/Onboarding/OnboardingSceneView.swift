//
//  OnboardingSceneView.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 15.09.2022.
//

import UIKit
import AppTrackingTransparency

class OnboardingSceneView: UIViewController, UD, Routerable, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum CellType {
        case welcome
        case cloud
        case distributed
        case backup
        
        var title: String {
            switch self {
            case .welcome:
                return Constants.Onboarding.welcome
            case .cloud:
                return Constants.Onboarding.personalCloud
            case .distributed:
                return Constants.Onboarding.distributedStorage
            case .backup:
                return Constants.Onboarding.passwordLess
            }
        }
        
        var image: UIImage {
            switch self {
            case .welcome:
                return AppImages.metaLogo
            case .cloud:
                return AppImages.distributedNetwork
            case .distributed:
                return AppImages.cloud
            case .backup:
                return AppImages.backup
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return Constants.Onboarding.whatIs
            case .cloud:
                return Constants.Onboarding.personalCloudDescription
            case .distributed:
                return Constants.Onboarding.distributedStorageDescription
            case .backup:
                return Constants.Onboarding.passwordLessDescription
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    private let cells: [CellType] = [.welcome, .cloud, .distributed, .backup]
    
    private struct Config {
        static let subtitleFont: CGFloat = 20
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        pageControl.numberOfPages = cells.count
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Functions
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(nibWithCellClass: OnboardingCollectionViewCell.self)
    }
    
    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: Any) {
        finishOnboarding()
    }
    
    @IBAction func nextPageButtonTapped(_ sender: Any) {
        let nextPage = pageControl.currentPage + 1
        if nextPage < pageControl.numberOfPages {
            collectionView.scrollToItem(at: IndexPath(row: nextPage, section: 0), at: .left, animated: true)
        } else {
            finishOnboarding()
        }
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: OnboardingCollectionViewCell.self, for: indexPath)
        cell.setup(cellType: cells[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page
    }
}

private extension OnboardingSceneView {
    func finishOnboarding() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization() { _ in
                DispatchQueue.main.async {
                    self.routeTo(.login, presentAs: .root)
                }
            }
        } else {
            routeTo(.login, presentAs: .root)
        }
        shouldShowOnboarding = false
    }
}
