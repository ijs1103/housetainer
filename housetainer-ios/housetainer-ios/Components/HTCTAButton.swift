//
//  HTCTAButton.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/1/24.
//

import Foundation
import UIKit

final class HTCTAButton: UIButton{
    var isLoading: Bool{
        get { state.contains(.loading) }
        set{
            if newValue{
                _state.insert(.loading)
            }else{
                _state.remove(.loading)
            }
        }
    }
    override var isEnabled: Bool{
        didSet{
            refresh()
        }
    }
    override var isHighlighted: Bool{
        didSet{
            refresh()
        }
    }
    override var isSelected: Bool{
        didSet{
            refresh()
        }
    }
    var didTap: (() -> Void)?
    
    override var state: UIControl.State{
        [_state, super.state]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private var _state: UIControl.State = []{
        didSet{
            refresh()
        }
    }
    private var loadingView = {
        let view = UIActivityIndicatorView()
        view.color = Color.white
        return view
    }()
}

private extension UIControl.State{
    static let loading = Self(rawValue: 1 << 5)
}

private extension HTCTAButton{
    func setupUI(){
        addSubview(loadingView)
        
        titleLabel?.font = Typo.Title4()
        
        setTitleColor(Color.gray500, for: .disabled)
        setTitleColor(Color.white, for: .normal)
        
        setBackgroundColor(Color.gray200, for: .disabled)
        setBackgroundColor(Color.purple400, for: .normal)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        addTarget(self, action: #selector(didTapDoneAction), for: .touchUpInside)
        isEnabled = false
    }
    
    func define(){
        loadingView.snp.makeConstraints{
            $0.size.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }
    }
    
    func refresh(){
        loadingView.isHidden = !isLoading
        titleLabel?.isHidden = isLoading
        isUserInteractionEnabled = !isLoading
        
        if isLoading{
            loadingView.startAnimating()
        }else{
            loadingView.stopAnimating()
        }
    }
    
    @objc func didTapDoneAction(){
        didTap?()
    }
}
