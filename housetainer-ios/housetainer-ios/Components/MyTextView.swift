//
//  MyTextView.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/3/24.
//

import Foundation
import UIKit
import CoreGraphics
import Combine

final class MyTextView: UITextView {
    
    var textLimit: Int = 500 {
        didSet {
            refreshCounter()
        }
    }
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification, object: self
        )
        .compactMap{ $0.object as? UITextView}
        .map{ $0.text ?? "" }
        .eraseToAnyPublisher()
    }

    var placeholder: String = "" {
        didSet {
            placeholderTextView.text = placeholder
        }
    }
    
    override var text: String!{
        didSet {
            refreshPlaceholder()
            refreshCounter()
        }
    }
    
    override var attributedText: NSAttributedString!{
        didSet {
            refreshPlaceholder()
            refreshCounter()
        }
    }
    
    override var textContainerInset: UIEdgeInsets{
        didSet {
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
        addDoneButtonOnKeyboard()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderTextView.frame.origin = .zero
        placeholderTextView.frame.size = self.bounds.size
        
        let counterSize = counterLabel.sizeThatFits(self.bounds.size)
        counterLabel.frame.size = counterSize
        counterLabel.frame.origin = CGPoint(x: self.bounds.maxX - counterSize.width - 12, y: self.bounds.maxY - counterSize.height - 8)
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: counterSize.height + 12 * 2, right: 12)
    }
    
    private let placeholderTextView = {
        let textView = UITextView()
        textView.font = Typo.Body2()
        textView.textColor = Color.gray400
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let counterLabel = {
        let label = UILabel()
        label.font = Typo.Body4()
        label.textColor = Color.gray400
        label.text = ""
        return label
    }()
}

extension MyTextView {
    private func setupUI(){
        backgroundColor = Color.white
        font = Typo.Body1()
        textColor = Color.black
        isScrollEnabled = false
        textContainer.lineFragmentPadding = .zero
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 39, right: 12)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = Color.gray200.cgColor
        layer.masksToBounds = true
        
        addSubview(placeholderTextView)
        addSubview(counterLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTextAction), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc private func didChangeTextAction(){
        refreshPlaceholder()
        refreshCounter()
        handleLimit()
    }
    
    private func refreshPlaceholder(){
        placeholderTextView.isHidden = !text.isEmpty
    }
    
    private func refreshCounter(){
        counterLabel.text = "\(text.count)/\(textLimit)"
        setNeedsLayout()
    }
    
    private func handleLimit() {
        if text.count >= textLimit {
            counterLabel.text = "\(textLimit)/\(textLimit)"
            text = text.stringWithCharacterLimit(max: textLimit)
        }
    }
        
    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title:  NSLocalizedString("완료", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        doneButton.tintColor = Color.purple300
        doneToolbar.items = [flexibleSpace, doneButton]
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction(){
        resignFirstResponder()
    }
}
