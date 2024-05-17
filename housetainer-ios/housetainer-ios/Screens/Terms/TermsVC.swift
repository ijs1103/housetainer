//
//  TermsVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/15/24.
//

import UIKit
import SnapKit

final class TermsVC: UIViewController {
    
    private let type: AgreementType
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .white
        textView.font = Typo.Body3()
        textView.textColor = Color.gray700
        textView.text = type.content
        return textView
    }()
    
    init(type: AgreementType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
}

extension TermsVC {
    private func setupNavigationBar() {
        let customView = UIImageView(image: Icon.close)
        customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClose)))
        customView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        navigationItem.hidesBackButton = true
        let titleView = LabelFactory.build(text: type.title, font: Typo.Heading2(), textColor: Color.gray800)
        navigationItem.titleView = titleView
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
