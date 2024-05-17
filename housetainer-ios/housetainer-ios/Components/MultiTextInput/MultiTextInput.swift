//
//  MultiTextInput.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import CoreGraphics
import SwiftUI
import Combine

final class MultiTextInput: UITextView{
    private let textChangePublisher = PassthroughSubject<String, Never>()

    var placeholder: String = ""{
        didSet{
            placeholderTextView.text = placeholder
        }
    }
    var didChangeText: ((String) -> Void)?
    override var text: String!{
        didSet{
            refreshPlaceholder()
            refreshCounter()
        }
    }
    override var attributedText: NSAttributedString!{
        didSet{
            refreshPlaceholder()
            refreshCounter()
        }
    }
    override var textContainerInset: UIEdgeInsets{
        didSet{
            placeholderTextView.textContainerInset = textContainerInset
        }
    }
    
    override var intrinsicContentSize: CGSize{
        let placeholderSize = placeholderTextView.intrinsicContentSize
        let textSize = super.intrinsicContentSize
        return CGSize(width: max(placeholderSize.width, textSize.width), height: max(placeholderSize.height, textSize.height))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let placeholderSize = placeholderTextView.sizeThatFits(size)
        let textSize = super.sizeThatFits(size)
        return CGSize(width: max(placeholderSize.width, textSize.width), height: max(placeholderSize.height, textSize.height))
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
        refreshCounter()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderTextView.frame.origin = .zero
        placeholderTextView.frame.size = self.bounds.size
        
        let counterSize = counterLabel.sizeThatFits(self.bounds.size)
        counterLabel.frame.size = counterSize
        counterLabel.frame.origin = CGPoint(x: self.bounds.maxX - counterSize.width - 12, y: self.bounds.maxY - counterSize.height - 8)
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: counterSize.height + 16 * 2, right: 16)
    }
    
    // MARK: - UI Properties
    private let placeholderTextView = {
        let textView = UITextView()
        textView.font = Typo.Body1()
        textView.textColor = Color.gray300
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let counterLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray300
        label.text = "adasdasdasd"
        return label
    }()
}

extension MultiTextInput {
    func textPublisher() -> AnyPublisher<String, Never> {
        return textChangePublisher.eraseToAnyPublisher()
    }
}

private extension MultiTextInput{
    func setupUI(){
        backgroundColor = Color.white
        font = Typo.Body1()
        textColor = Color.black
        isScrollEnabled = false
        textContainer.lineFragmentPadding = .zero
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 43, right: 16)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = Color.gray150.cgColor
        layer.masksToBounds = true
        
        addSubview(placeholderTextView)
        addSubview(counterLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTextAction), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc func didChangeTextAction(){
        refreshPlaceholder()
        refreshCounter()
        didChangeText?(self.text.ifNil(then: ""))
        textChangePublisher.send(text)
    }
    
    func refreshPlaceholder(){
        placeholderTextView.isHidden = !text.isEmpty
    }
    
    func refreshCounter(){
        counterLabel.text = "\(text.count)/1000"
        setNeedsLayout()
    }
}

struct MultiTextInput_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let textField = MultiTextInput()
            textField.placeholder = """
            이런 내용을 포함하면 좋아요.
            - 행사/공간 성격
            - 참석 이유
            - 만나면 하고싶은 이야기
            - 함께 하는 사람
            """
            return textField
        }
    }
}

