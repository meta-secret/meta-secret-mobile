//
//  String+Extension.swift
//  MetaSecret
//
//  Created by Dmitry Kuklin on 06.09.2022.
//

import UIKit
import Foundation

extension String {
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
    
    func withBoldText(boldPartsOfString: Array<NSString>, font: UIFont, boldFont: UIFont) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font: font]
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont]
        let boldString = NSMutableAttributedString(string: self as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: (self as NSString).range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }
}
