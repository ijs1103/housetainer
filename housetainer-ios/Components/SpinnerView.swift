//
//  SpinnerView.swift
//  housetainer-ios
//
//  Created by 이주상 on 12/15/23.
//

import UIKit

final class SpinnerView: UICollectionReusableView {
    
    static let id = "SpinnerView"
    private let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    func toggleLoading(isEnabled: Bool) {
        if isEnabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
