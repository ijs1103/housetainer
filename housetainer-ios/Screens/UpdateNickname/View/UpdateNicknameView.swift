//
//  UpdateNicknameView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/16/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class UpdateNicknameView: UIView{
    var didChangeNickname: ((String) -> Void)?
    var didTapDone: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        scrollView.contentInset.bottom = 20 + doneButton.frame.height + 20
    }
    
    func updateNickname(_ nickname: UserNickname){
        if nicknameTextInput.text != nickname.nickname{
            nicknameTextInput.text = nickname.nickname
        }
        doneButton.isEnabled = nickname.canUpdate
    }
    
    func updateError(_ error: String){
        nicknameInputLayout.error = error
    }
    
    // MARK: - UI Properties
    private let scrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        return scrollView
    }()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 32, left: 20, bottom: 32, right: 20)
        return view
    }()
    private lazy var nicknameTextInput = {
        let textInput = TextInput()
        textInput.clearButtonMode = .whileEditing
        textInput.isCounterHidden = false
        textInput.maxLength = 10
        textInput.addTarget(self, action: #selector(didChangeNicknameAction), for: .editingChanged)
        return textInput
    }()
    private lazy var nicknameInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "닉네임"
        inputLayout.error = ""
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return nicknameTextInput
        }
        return inputLayout
    }()
    private lazy var doneButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Title4()
        button.setTitleColor(Color.gray500, for: .disabled)
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle("작성 완료", for: .normal)
        button.setBackgroundColor(Color.gray200, for: .disabled)
        button.setBackgroundColor(Color.purple400, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapDoneAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: Private
}

private extension UpdateNicknameView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        addSubview(doneButton)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(nicknameInputLayout)
    }
    
    func define(){
        scrollView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        scrollContainer.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        nicknameInputLayout.snp.makeConstraints{
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalTo(scrollContainer.snp.bottomMargin)
        }
        
        doneButton.snp.makeConstraints{
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide.snp.directionalHorizontalEdges).inset(20)
            $0.height.equalTo(52)
        }
    }
    
    @objc func didChangeNicknameAction(){
        didChangeNickname?(nicknameTextInput.text.ifNil(then: ""))
    }
    
    @objc func didTapDoneAction(){
        didTapDone?()
    }
    
    @objc func keyboardWillShowNotification(_ notification: NSNotification){
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else{ return }
        scrollView.contentInset.bottom = endFrame.height - self.safeAreaInsets.bottom
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
}

struct UpdateNicknameView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = UpdateNicknameView()
            return view
        }
    }
}
