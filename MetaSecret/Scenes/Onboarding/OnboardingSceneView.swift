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
    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var mobileMainImage: UIImageView!
    @IBOutlet weak var computerImage: UIImageView!
    @IBOutlet weak var animationOnboardingContainer: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var cloudImage: UIImageView!
    @IBOutlet weak var missingImage: UIImageView!
    
    // MARK: - Properties
    private let cells: [CellType] = [.cloud, .distributed, .backup]
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    // MARK: - Functions
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
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
        
        switch nextPage {
        case 0:
            setupFirstAnimatedStep()
        case 1:
            setupSecondAnimatedStep()
        case 2:
            setupThirdAnimatedStep()
        default:
            break
        }
        
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
    func setupUI() {
        mobileMainImage.center = logoImage.center
        mobileImage.center = mobileMainImage.center
        computerImage.center = computerImage.center
    }
    
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
    
    func setupFirstAnimatedStep() {
        mobileMainImage.isHidden = false
        UIView.animate(withDuration: Constants.Common.animationTime,  animations: {
            self.logoImage.alpha = 0
        }, completion: nil)
    }
    
    func setupSecondAnimatedStep() {
        mobileImage.center = mobileMainImage.center
        computerImage.center = mobileMainImage.center
        
        mobileImage.isHidden = false
        computerImage.isHidden = false
        
        let originMainMobileTransform = mobileMainImage.transform
        let scaledMainMobileTransform = originMainMobileTransform.scaledBy(x: 0.65, y: 0.65)
        let finalMainMobileY = animationOnboardingContainer.frame.height - mobileMainImage.frame.height - mobileMainImage.frame.height/2
        let mainMobileDeltaY = mobileMainImage.frame.origin.y + finalMainMobileY
        let scaledAndTranslatedMainMobileTransform = scaledMainMobileTransform.translatedBy(x: 0.0, y: mainMobileDeltaY)
        
        let originMobileTransform = mobileImage.transform
        let finalMobileY = animationOnboardingContainer.frame.height - mobileImage.frame.height - 16
        let mobileDeltaY = mobileImage.frame.origin.y - finalMobileY
        let finalMobileX = animationOnboardingContainer.frame.width - mobileImage.frame.width - 16
        let mobileDeltaX = mobileImage.frame.origin.x - finalMobileX
        let translatedMobileTransform = originMobileTransform.translatedBy(x: mobileDeltaX, y: mobileDeltaY)
        
        let originComputerTransform = computerImage.transform
        let finalComputerY = animationOnboardingContainer.frame.height - computerImage.frame.height - 16
        let computerDeltaY = computerImage.frame.origin.y - finalComputerY
        let finalComputerX = animationOnboardingContainer.frame.width - mobileImage.frame.width - 16
        let computerDeltaX = finalComputerX - mobileImage.frame.origin.x
        let translatedComputerTransform = originComputerTransform.translatedBy(x: computerDeltaX, y: computerDeltaY)
        
        UIView.animate(withDuration: 0.3) {
            self.mobileMainImage.transform = scaledAndTranslatedMainMobileTransform
            self.mobileImage.transform = translatedMobileTransform
            self.computerImage.transform = translatedComputerTransform
        } completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.cloudImage.alpha = 1
            })
        }
    }
    
    func setupThirdAnimatedStep() {
        missingImage.frame.origin = mobileImage.frame.origin
        
        UIView.animate(withDuration: 0.3) {
            self.mobileImage.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.missingImage.alpha = 1
            })
        }
    }
}
