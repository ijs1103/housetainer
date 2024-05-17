//
//  Bundle+.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/15/24.
//

import UIKit

extension Bundle {
    func loadRTFFile(named fileName: String, withExtension fileExtension: String = "rtf") -> String {
        if let filePath = self.path(forResource: fileName, ofType: fileExtension) {
            do {
                let rtfData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                let attributedString = try NSAttributedString(data: rtfData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                return attributedString.string
            } catch {
                print("Error loading RTF file: \(error)")
            }
        }
        return ""
    }
}
