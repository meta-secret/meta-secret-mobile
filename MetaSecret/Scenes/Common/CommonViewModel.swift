//
//  CommonViewModel.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 29.12.2022.
//

import Foundation
import PromiseKit

class CommonViewModel {
    var isDataLoaded: Bool = false
    var isLoadingData: Bool = false
    var isSavingData: Bool = false
    
    var title: String {
        return ""
    }
    
    func loadData() -> Promise<Void> {
        return Promise.value(())
    }
    
    func saveData() -> Promise<Void> {
        return Promise.value(())
    }
}
