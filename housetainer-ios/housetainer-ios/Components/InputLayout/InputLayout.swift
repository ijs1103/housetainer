//
//  InputLayout.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Combine

final class InputLayout: UIView{
    var title: String = ""{
        didSet{
            guard oldValue != title else{ return }
            refreshTitle()
        }
    }
    var attributedTitle: NSAttributedString?{
        didSet{
            guard oldValue != attributedTitle else{ return }
            refreshTitle()
        }
    }
    var spacing: CGFloat = 16{
        didSet{
            guard oldValue != spacing else{ return }
            refreshSpacing()
        }
    }
    var underlineWidth: CGFloat = 0{
        didSet{
            guard oldValue != underlineWidth else{ return }
            refreshUnderline()
        }
    }
    var underlineColor: UIColor = Color.gray150{
        didSet{
            guard oldValue != underlineColor else{ return }
            refreshUnderline()
        }
    }
    var inputViewBuilder: (() -> UIView)?{
        didSet{
            refreshInputViewBuilder()
        }
    }
    var error: String = ""{
        didSet{
            guard oldValue != error else{ return }
            errorLabel.text = error
            refreshError()
        }
    }
    var didChangeText: ((String ) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        refreshTitle()
        refreshInputViewBuilder()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else{ return }
        
        context.setStrokeColor(underlineColor.cgColor)
        context.setLineWidth(underlineWidth)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.closePath()
        context.strokePath()
    }
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body1SemiBold()
        label.textColor = Color.gray800
        label.numberOfLines = 0
        return label
    }()
    private weak var _inputView: UIView?
    private let errorLabel = {
        let label = UILabel()
        label.font = Typo.Body4()
        label.textColor = Color.red200
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Private
}

extension InputLayout {
    func inputText() -> String? {
        (_inputView as? MultiTextInput)?.text
    }
    
    func setInputText(_ text: String) {
        (_inputView as? MultiTextInput)?.text = text
    }
    
    func textPublisher() -> AnyPublisher<String, Never>? {
        (_inputView as? MultiTextInput)?.textPublisher()
    }
}

private extension InputLayout{
    func setupUI(){
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(errorLabel)
    }
    
    func define(){
        titleLabel.snp.makeConstraints{
            $0.top.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(errorLabel.snp.top).priority(.low)
        }
        errorLabel.snp.makeConstraints{
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func refreshTitle(){
        if let attributedTitle{
            titleLabel.attributedText = attributedTitle
        }else{
            titleLabel.text = title
        }
        
        _inputView?.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(title.isEmpty ? 0 : spacing)
        }
    }
    
    func refreshInputViewBuilder(){
        _inputView?.removeFromSuperview()
        
        if let inputView = inputViewBuilder?(){
            addSubview(inputView)
            inputView.snp.makeConstraints{
                $0.top.equalTo(titleLabel.snp.bottom).offset(spacing)
                $0.directionalHorizontalEdges.equalToSuperview()
                $0.bottom.equalTo(errorLabel.snp.top).offset(-10)
            }
            
            _inputView = inputView
            refreshError()
            refreshTitle()
        }
    }
    
    func refreshSpacing(){
        _inputView?.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(spacing)
        }
    }
    
    func refreshError(){
        _inputView?.snp.updateConstraints{
            $0.bottom.equalTo(errorLabel.snp.top).offset(error.isEmpty ? 0 : -10)
        }
    }
    
    func refreshUnderline(){
        setNeedsDisplay()
    }
}

struct InputLayout_Previews: PreviewProvider{
    static var previews: some View{
        VStack{
            ViewPreview{
                let inputLayout = InputLayout()
                inputLayout.title = "제목"
                inputLayout.underlineWidth = 1
                inputLayout.error = "에러"
                inputLayout.backgroundColor = .red
                inputLayout.inputViewBuilder = {
                    let textInput = TextInput()
                    textInput.underlineWidth = 0
                    textInput.placeholder = "제목을 입력해주세요."
                    textInput.backgroundColor = .blue
                    return textInput
                }
                return inputLayout
            }
            
            ViewPreview{
                let inputLayout = InputLayout()
                inputLayout.title = "제목"
                inputLayout.underlineWidth = 1
                inputLayout.backgroundColor = .red
                inputLayout.inputViewBuilder = {
                    let textInput = TextInput()
                    textInput.underlineWidth = 0
                    textInput.placeholder = "제목을 입력해주세요."
                    textInput.backgroundColor = .blue
                    return textInput
                }
                return inputLayout
            }
        }
    }
}
