//
//  MyTextField.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/09.
//

import UIKit
import Combine

struct MyTextFieldConfig {
    let label: String?
    let isLabelRequired: Bool
    let placeholder: String
    let errMessage: String
    let limit: Int?
    let keyboardType: UIKeyboardType
}

protocol MyTextFieldDelegate: AnyObject {
    func clearButtonTapped()
}

final class MyTextField: UIView {
    
    weak var delegate: MyTextFieldDelegate?
    private var subscriptions = Set<AnyCancellable>()
    private let limit: Int?
    
    private let textLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray600)
    }()
    
    lazy var textField: UITextField = {
        let bottomPadding: CGFloat = 8
        var textField = TextFieldWithPadding(padding: UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0))
        textField.font = Typo.Body1()
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.delegate = self
        textField.addBorder(side: .bottom, color: Color.gray400, width: 1)
        return textField
    }()
    
    private let limitLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray400)
        label.isHidden = true
        label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        label.textAlignment = .right
        return label
    }()
    
    private let errMessage: UILabel = {
        let label = UILabel()
        let style = NSMutableParagraphStyle()
        let lineheight = 18.0
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        label.attributedText = NSAttributedString(
            string: "", attributes: [
                .paragraphStyle: style
            ])
        label.font = Typo.Body4()
        label.textColor = Color.red200
        label.numberOfLines = 2
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textLabel, textField, limitLabel, errMessage])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()
    
    
    init(config: MyTextFieldConfig) {
        self.limit = config.limit
        super.init(frame: .zero)
        if let limit {
            self.limitLabel.text = "0/\(limit)"
            self.limitLabel.isHidden = false
        }
        if let labelText = config.label {
            if config.isLabelRequired {
                self.textLabel.attributedText = NSMutableAttributedString().regularLabel(string: labelText).requiredLabel()
            } else {
                self.textLabel.text = labelText
            }
        }
        self.textField.attributedPlaceholder = NSAttributedString(string: config.placeholder, attributes: [.foregroundColor: Color.gray400, .font: Typo.Body1()])
        self.errMessage.text = config.errMessage
        self.textField.keyboardType = config.keyboardType
        setUI()
        setCustomClearButton(image: Icon.inputClear!)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyTextField {
    func toggleError(hasError: Bool) {
        textField.removeBorder()
        if hasError {
            textField.addBorder(side: .bottom, color: Color.red200, width: 1)
            errMessage.isHidden = false
        } else {
            textField.addBorder(side: .bottom, color: Color.gray400, width: 1)
            errMessage.isHidden = true
        }
        if limit != nil {
            limitLabel.isHidden = hasError
        }
    }
    
    private func setUI() {
        [vStack].forEach {
            self.addSubview($0)
        }
        textField.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setCustomClearButton(image: UIImage) {
        let image = UIImageView(image: image)
        image.contentMode = .scaleAspectFit
        let paddingView = SpacingFactory.build(height: 8)
        let vStack = UIStackView(arrangedSubviews: [image, paddingView])
        vStack.axis = .vertical
        vStack.alignment = .center
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapClearButton))
        vStack.addGestureRecognizer(tgr)
        vStack.isUserInteractionEnabled = true
        textField.rightView = vStack
        textField.rightViewMode = .never
    }
    
    private func toggleClearButton(isHidden: Bool) {
        textField.rightViewMode = isHidden ? .never : .always
    }
    
    @objc private func didTapClearButton() {
        textField.text = ""
        textField.rightViewMode = .never
        if let limit = self.limit {
            limitLabel.text = "0/\(limit)"
        }
        delegate?.clearButtonTapped()
    }
    
    private func bind() {
        textField.publisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] text in
                toggleClearButton(isHidden: text.isEmpty)
                if let limit {
                    checkLimit(text)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func checkLimit(_ text: String) {
        guard let limit = self.limit else { return }
        limitLabel.text = "\(text.count)/\(limit)"
    }
}

extension MyTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.removeBorder()
        textField.addBorder(side: .bottom, color: Color.purple300, width: 1)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.removeBorder()
        textField.addBorder(side: .bottom, color: Color.gray400, width: 1)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.removeBorder()
        textField.addBorder(side: .bottom, color: Color.gray400, width: 1)
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

