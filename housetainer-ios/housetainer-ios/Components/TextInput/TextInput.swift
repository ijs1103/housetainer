//
//  TextInput.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import CoreGraphics
import SwiftUI

final class TextInput: UITextField{
    var contentEdgeInsets: UIEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
    var placeholderColor: UIColor = UIColor.black {
        didSet{
            guard oldValue != placeholderColor else{ return }
            //refreshPlaceholderColor()
        }
    }
    var underlineWidth: CGFloat = 1{
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
    var highlightColor: UIColor = Color.purple300{
        didSet{
            guard oldValue != highlightColor else{ return }
            refreshUnderline()
        }
    }
    var isCounterHidden: Bool = true{
        didSet{
            guard oldValue != isCounterHidden else{ return }
            refreshCounter()
            invalidateIntrinsicContentSize()
        }
    }
    var maxLength: Int = 0{
        didSet{
            guard oldValue != maxLength else{ return }
            trimText()
            refreshCounter()
            invalidateIntrinsicContentSize()
        }
    }
    override var text: String?{
        didSet{
            trimText()
        }
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return textAreaRect(forBounds: super.textRect(forBounds: bounds))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textAreaRect(forBounds: super.editingRect(forBounds: bounds))
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        super.leftViewRect(forBounds: textAreaRect(forBounds: bounds))
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: textAreaRect(forBounds: bounds))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        super.clearButtonRect(forBounds: textAreaRect(forBounds: bounds))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: UITextField.textDidEndEditingNotification, object: self)
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
        layout()
    }
    
    override func draw(_ rect: CGRect) {
        let newRect = {
            if isCounterHidden{
                return rect
            }
            
            let counterSize = counterLabel.sizeThatFits(rect.size)
            var newRect = rect
            newRect.size.height -= counterSize.height + 2
            return newRect
        }()
        super.draw(newRect)
        
        guard let context = UIGraphicsGetCurrentContext() else{ return }
        if isEditing{
            highlightColor.setStroke()
        }else{
            underlineColor.setStroke()
        }
        
        context.setLineWidth(underlineWidth)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: newRect.maxY))
        context.addLine(to: CGPoint(x: newRect.maxX, y: newRect.maxY))
        context.closePath()
        context.drawPath(using: .stroke)
    }
    
    // MARK: - UI Properties
    private let counterLabel = {
        let label = UILabel()
        label.textColor = Color.gray300
        label.font = Typo.Caption1()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private
}

private extension TextInput{
    func setupUI(){
        font = Typo.Body1()
        textColor = Color.black
        placeholderColor = Color.black
        addSubview(counterLabel)
        
        refreshCounter()
        textDidChange()
    }
    
    func define(){
        
    }
    
    func layout(){
        let counterSize = counterLabel.sizeThatFits(bounds.size)
        counterLabel.frame = CGRect(
            origin: CGPoint(
                x: bounds.width - counterSize.width,
                y: bounds.height - counterSize.height
            ),
            size: counterSize
        )
    }
    
    func refreshPlaceholderColor(){
        let attributedString = NSMutableAttributedString(attributedString: attributedPlaceholder ?? NSAttributedString(string: placeholder ?? ""))
        attributedString.setAttributes([
            .foregroundColor: UIColor.black.cgColor
        ], range: NSMakeRange(0, attributedString.length))
        self.attributedPlaceholder = attributedString
    }
    
    func refreshUnderline(){
        setNeedsDisplay()
    }
    
    func refreshCounter(){
        counterLabel.isHidden = isCounterHidden || maxLength == 0
    }
    
    func textAreaRect(forBounds bounds: CGRect) -> CGRect {
        if isCounterHidden{
            return bounds.inset(by: contentEdgeInsets)
        }
        
        let counterSize = counterLabel.sizeThatFits(bounds.size)
        var newBounds = bounds.inset(by: contentEdgeInsets)
        newBounds.size.height -= counterSize.height + 2
        return newBounds
    }
    
    func trimText(){
        if maxLength > 0, let text, text.count > maxLength{
            self.text = String(text.prefix(maxLength))
        }
        counterLabel.text = "\(text?.count ?? 0)/\(maxLength)"
        setNeedsLayout()
    }
    
    @objc func textDidBeginEditing(){
        setNeedsDisplay()
    }
    
    @objc func textDidChange(){
        trimText()
    }
    
    @objc func textDidEndEditing(){
        setNeedsDisplay()
    }
}

struct TextInput_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let textField = TextInput()
            textField.placeholder = "제목을 입력해주세요"
            return textField
        }
    }
}
