//
//  BiometricsManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 05.02.2023.
//

import Foundation
import LocalAuthentication
import PromiseKit

protocol BiometricsManagerProtocol {
    func canEvaluate() -> Promise<Bool>
    func evaluate() -> Promise<(Bool, BiometricError?)>
}

final class BiometricsManager: NSObject, BiometricsManagerProtocol {
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    override init() {
        self.policy = .deviceOwnerAuthentication
        self.localizedReason = Constants.Alert.biometricalReason
        context.localizedFallbackTitle = Constants.BiometricError.enterAppPass
        context.localizedCancelTitle = nil
    }
    
    func canEvaluate() -> Promise<Bool> {
        guard context.canEvaluatePolicy(policy, error: &error) else {
            let type = biometricType(for: context.biometryType)
            guard error == nil else {
                return Promise<Bool> { seal in
                    seal.fulfill(false)
                }
            }
            return Promise<Bool> { seal in
                seal.fulfill(true)
            }
        }
        return Promise<Bool> { seal in
            seal.fulfill(true)
        }
    }
    
    func evaluate() -> Promise<(Bool, BiometricError?)> {
        return Promise<(Bool, BiometricError?)> { seal in
            context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        seal.fulfill((true, nil))
                    } else {
                        guard let error = error else { return seal.fulfill((false, nil)) }
                        seal.fulfill((false, self?.biometricError(from: error as NSError)))
                    }
                }
            }
        }
    }
    
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .unknown
        }
    }
    
    fileprivate func biometricError(from nsError: NSError) -> BiometricError {
        let error: BiometricError
        
        switch nsError {
        case LAError.authenticationFailed:
            error = .authenticationFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
            error = .userFallback
        case LAError.biometryNotAvailable:
            error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            error = .biometryNotEnrolled
        case LAError.biometryLockout:
            error = .biometryLockout
        default:
            error = .unknown
        }
        
        return error
    }
}

enum BiometricError: LocalizedError {
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed: return Constants.BiometricError.authenticationFailed
        case .userCancel: return Constants.BiometricError.userCancel
        case .userFallback: return Constants.BiometricError.userFallback
        case .biometryNotAvailable: return Constants.BiometricError.biometryNotAvailable
        case .biometryNotEnrolled: return Constants.BiometricError.biometryNotEnrolled
        case .biometryLockout: return Constants.BiometricError.biometryLockout
        case .unknown: return Constants.BiometricError.unknown
        }
    }
}

enum BiometricType {
    case none
    case touchID
    case faceID
    case unknown
}
