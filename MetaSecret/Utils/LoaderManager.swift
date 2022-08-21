//
//  LoaderManager.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 21.08.2022.
//

import Foundation
import UIKit

protocol Loaderable: RootFindable {
    func showLoader()
    func hideLoader()
}

extension Loaderable {
    func showLoader() {
        let window = findWindow()
        
        let isAlreadyLoader = window?.subviews.contains(where: {$0.tag == Constants.ViewTags.loaderTag}) ?? false
        guard !isAlreadyLoader else { return }
        
        let bgView = UIView(frame: window?.frame ?? CGRect.zero)
        bgView.backgroundColor = AppColors.alphaBlack40
        
        let loginSpinner = UIActivityIndicatorView(style: .medium)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        loginSpinner.center = bgView.center
        bgView.addSubview(loginSpinner)
        
        loginSpinner.startAnimating()
        
        bgView.tag = Constants.ViewTags.loaderTag
        window?.addSubview(bgView)
    }
    
    func hideLoader() {
        let window = findWindow()
        
        let loaderView = window?.subviews.first(where: {$0.tag == Constants.ViewTags.loaderTag})
        loaderView?.removeFromSuperview()
    }
}
