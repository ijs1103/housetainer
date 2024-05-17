//
//  CommentInput.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/27.
//

import UIKit
import SnapKit

protocol CommentInputDelegate: AnyObject {
    func didTapRegister(text: String?)
}

final class CommentInput: UIView {
    weak var delegate: CommentInputDelegate?
    
    private lazy var textField: UITextField = {
        let textField = TextFieldWithPadding(padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 58))
        textField.attributedPlaceholder = NSAttributedString(string: Placeholder.comment, attributes: [NSAttributedString.Key.foregroundColor : Color.gray300])
        textField.font = Typo.Body3()
        textField.textColor = Color.gray700
        textField.backgroundColor = .white
        textField.layer.borderColor = Color.gray150.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        textField.layer.masksToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var registerButton: UILabel = {
        let label = LabelFactory.build(text: Title.register, font: Typo.Body3(), textColor: Color.gray600)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapRegister))
        label.addGestureRecognizer(tgr)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    init(placeholder: String) {
        super.init(frame: .zero)
        setUI()
        textField.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CommentInput {
    private func setUI() {
        backgroundColor = .white
        addBorder(side: .top, color: Color.gray100, width: 1.0)
        heightAnchor.constraint(equalToConstant: 112).isActive = true
        
        [ textField, registerButton ].forEach {
            addSubview($0)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        registerButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField.snp.centerY)
            make.trailing.equalTo(textField.snp.trailing).offset(-12)
        }
    }
    
    @objc private func didTapRegister() {
        delegate?.didTapRegister(text: textField.text)
    }
    
    func clearText() {
        textField.text = nil
    }
}

extension CommentInput: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.purple100.cgColor
        registerButton.textColor = Color.purple500
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.gray150.cgColor
        registerButton.textColor = Color.gray600
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = Color.gray150.cgColor
        registerButton.textColor = Color.gray600
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
