//
//  InviteUserView.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import SnapKit
import UIKit
import SwiftUI

final class InviteUserView: UIView{
    var didChangeName: ((String) -> Void)?
    var didChangeEmail: ((String) -> Void)?
    var didTapDone: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    func updateInviteUser(_ inviteUser: InviteUser){
        if buddyNameTextInput.text != inviteUser.name{
            buddyNameTextInput.text = inviteUser.name
        }
        if buddyEmailTextInput.text != inviteUser.email{
            buddyEmailTextInput.text = inviteUser.email
        }
        doneButton.isEnabled = inviteUser.canUpdate
    }
    
    // MARK: - UI Properties
    private let scrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        return view
    }()
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Heading1()
        label.textColor = Color.black
        label.numberOfLines = 0
        label.text = """
        홈버디 초대
        """
        return label
    }()
    private let subtitleLabel = {
        let label = UILabel()
        label.font = Typo.Body2()
        label.textColor = Color.black
        label.numberOfLines = 0
        label.text = """
        좋은 친구를 홈버디로 등록하면 집초대 기회가 높아집니다.
        홈버디는 2명까지만 초대 가능해요!
        """
        return label
    }()
    private lazy var buddyNameTextInput = {
        let input = TextInput()
        input.placeholder = "홈버디 이름"
        input.clearButtonMode = .whileEditing
        input.keyboardType = .default
        input.addTarget(self, action: #selector(didChangeNameAction), for: .editingChanged)
        return input
    }()
    private lazy var buddyNameInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return buddyNameTextInput
        }
        return inputLayout
    }()
    private lazy var buddyEmailTextInput = {
        let input = TextInput()
        input.placeholder = "홈버디 이메일"
        input.clearButtonMode = .whileEditing
        input.keyboardType = .emailAddress
        input.addTarget(self, action: #selector(didChangeEmailAction), for: .editingChanged)
        return input
    }()
    private lazy var buddyEmailInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return buddyEmailTextInput
        }
        return inputLayout
    }()
    private lazy var doneButton = {
        let button = UIButton()
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        button.setTitle("초대 이메일 보내기", for: .normal)
        button.setBackgroundColor(Color.purple400, for: .normal)
        button.setBackgroundColor(Color.gray200, for: .disabled)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDoneAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: Private
}

private extension InviteUserView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(titleLabel)
        scrollContainer.addSubview(subtitleLabel)
        scrollContainer.addSubview(buddyNameInputLayout)
        scrollContainer.addSubview(buddyEmailInputLayout)
        addSubview(doneButton)
    }
    
    func define(){
        scrollView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        scrollContainer.snp.makeConstraints{
            $0.edges.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        subtitleLabel.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        buddyNameInputLayout.snp.makeConstraints{
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        buddyEmailInputLayout.snp.makeConstraints{
            $0.top.equalTo(buddyNameInputLayout.snp.bottom).offset(34)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalTo(scrollContainer.snp.bottomMargin)
        }
        
        doneButton.snp.makeConstraints{
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide.snp.directionalHorizontalEdges).inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
    
    func layout(){
        
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification){
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else{ return }
        let keyboardHeight: CGFloat = if let screenHeight = window?.screen.bounds.height{
            max(0, screenHeight - endFrame.minY - self.safeAreaInsets.bottom)
        }else{
            0
        }
        doneButton.snp.updateConstraints{
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(keyboardHeight + 20)
        }
        scrollView.contentInset.bottom = keyboardHeight - self.safeAreaInsets.bottom + doneButton.frame.height + 20
    }
    
    @objc func didChangeNameAction(){
        didChangeName?(buddyNameTextInput.text.ifNil(then: ""))
    }
    @objc func didChangeEmailAction(){
        didChangeEmail?(buddyEmailTextInput.text.ifNil(then: ""))
    }
    @objc func didTapDoneAction(){
        didTapDone?()
    }
}

struct InviteUserView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = InviteUserView()
            return view
        }
    }
}
