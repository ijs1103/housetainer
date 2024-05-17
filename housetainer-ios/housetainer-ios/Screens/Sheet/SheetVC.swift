//
//  SheetVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/20/24.
//

import Foundation
import UIKit

protocol SheetDelegate: AnyObject {
    func sheetVC(didSelet item: SheetView.Item)
    
    func sheetVCDismiss()
}

final class SheetVC: BaseViewController{
    typealias Item = SheetView.Item
    
    var items: [Item] = []{
        didSet{
            guard isViewLoaded else{ return }
            sheetView.items = items
        }
    }
    var spanCount: Int = 1{
        didSet{
            guard isViewLoaded else{ return }
            sheetView.spanCount = spanCount
        }
    }
    weak var delegate: SheetDelegate?
    
    override func loadView() {
        view = sheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sheetView.items = items
        sheetView.spanCount = spanCount
        
        sheetView.didTapDim = { [weak self] in
            guard let self else{ return }
            
            delegate?.sheetVCDismiss()
            dismiss(animated: false)
        }
        sheetView.didTapItem = { [weak self] item in
            guard let self else{ return }
            
            delegate?.sheetVC(didSelet: item)
            dismiss(animated: false)
        }
    }
    
    // MARK: - Private
    private let sheetView = SheetView()
}
