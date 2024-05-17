//
//  Preview.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

struct ViewPreview: UIViewRepresentable{
    let viewProvider: (() -> UIView)
    
    func makeUIView(context: Context) -> some UIView {
        viewProvider()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
#endif
