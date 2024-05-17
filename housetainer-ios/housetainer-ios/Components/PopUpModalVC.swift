//
//  PopUpModalVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/4/24.
//

import UIKit
import SnapKit

enum ModalType {
    case reporting, asking
    var word: String {
        switch self {
        case .reporting:
            return "신고"
        case .asking:
            return "문의"
        }
    }
}

protocol PopUpModalDelegate: AnyObject {
    func didTapOkButton()
}

final class PopUpModalVC: UIViewController {
    
    private let type: ModalType
    
    weak var delegate: PopUpModalDelegate?
    
    private lazy var canvas: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel = LabelFactory.build(text: Title.modal(type: type), font: Typo.Heading2(), textColor: Color.gray800)
    
    private let contentLabel = UILabel()
    
    private lazy var okButton: UIButton = {
        let button = ButtonFactory.buildOutline(config: MyButtonConfig(title: "확인", font: Typo.Body2(), textColor: Color.purple400, bgColor: .white), borderColor: Color.purple400)
        button.addTarget(self, action: #selector(didTapOkButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel, okButton])
        stackView.axis = .vertical
        stackView.setCustomSpacing(12.0, after: titleLabel)
        stackView.setCustomSpacing(28.0, after: contentLabel)
        return stackView
    }()
    
    init(type: ModalType, delegate: PopUpModalDelegate) {
        self.type = type
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task {
            let email = await getEmail()
            await MainActor.run {
                updateContentLabel(type: type, email: email)
            }
        }
    }
    
    private static func create(
        type: ModalType,
        delegate: PopUpModalDelegate
    ) -> PopUpModalVC {
        let view = PopUpModalVC(type: type, delegate: delegate)
        return view
    }
}

extension PopUpModalVC {
    
    private func getEmail() async -> String {
        await NetworkService.shared.userInfo()?.email ?? "회원 이메일"
    }
    
    private func updateContentLabel(type: ModalType, email: String) {
        let string = Title.modalContent(type: type, email: email)
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: Typo.Body2(),
            .foregroundColor: Color.gray700
        ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        if let emailRange = string.range(of: email) {
            let nsRange = NSRange(emailRange, in: string)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: nsRange)
        }
        contentLabel.attributedText = attributedString
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.layoutIfNeeded()
    }

    @discardableResult
    static func present(
        initialView: UIViewController,
        type: ModalType,
        delegate: PopUpModalDelegate
    ) -> PopUpModalVC {
        let view = PopUpModalVC.create(type: type, delegate: delegate)
        view.modalPresentationStyle = .overFullScreen
        view.modalTransitionStyle = .coverVertical
        initialView.present(view, animated: true)
        return view
    }
    
    @objc func didTapOkButton(_ btn: UIButton) {
        delegate?.didTapOkButton()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(canvas)
        canvas.addSubview(vStack)
        
        canvas.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(335)
            make.height.equalTo(310)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(canvas.snp.top).offset(24)
            make.leading.equalTo(canvas.snp.leading).offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
    }
}
