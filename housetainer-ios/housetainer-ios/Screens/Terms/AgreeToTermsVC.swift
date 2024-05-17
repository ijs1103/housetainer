//
//  AgreeToTermsVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/14/24.
//

import UIKit
import SnapKit
import KakaoSDKAuth
import KakaoSDKUser
import Toast

final class AgreeToTermsVC: UIViewController {
    
    private var checkStatusArray = [false, false, false, false]
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.terms, font: Typo.Heading1())
    }()
    
    private let subtitleLabel: UILabel = {
        LabelFactory.build(text: Subtitle.terms, font: Typo.Body2(), textAlignment: .left)
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.setCustomSpacing(12.0, after: titleLabel)
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var agreementTable: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.estimatedRowHeight = 56.0
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AgreementCell.self, forCellReuseIdentifier: AgreementCell.id)
        return tableView
    }()
            
    private lazy var startButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: Title.start, font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AgreeToTermsVC {

    private func setupUI() {
        view.backgroundColor = .white

        [vStack, agreementTable, startButton].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        agreementTable.snp.makeConstraints { make in
            make.top.equalTo(vStack.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        startButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(agreementTable.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc private func didTapStartButton() {
        navigationController?.pushViewController(InviteVC(), animated: true)
    }
    
    func setupCloseButton() {
        let customView = UIImageView(image: Icon.close)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        customView.addGestureRecognizer(tgr)
        customView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        navigationItem.hidesBackButton = true
    }
    
    @objc private func didTapClose() {
        if AuthApi.hasToken() {
            UserApi.shared.logout { error in
                if error != nil {
                    print("kakao signout error")
                }
            }
        }
        NetworkService.shared.supabaseSignOut()
        navigationController?.popViewController(animated: false)
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        checkStatusArray[index].toggle()
        if index == 0 {
            // 전체 동의가 선택되면 모든 항목을 동일하게 설정
            let isAllAgreementSelected = checkStatusArray[0]
            for index in 1..<checkStatusArray.count {
                checkStatusArray[index] = isAllAgreementSelected
            }
            startButton.toggleEnabledState(isAllAgreementSelected)
        } else {
            // 개별 항목이 선택되면 전체 동의 상태를 업데이트
            let allSelected = checkStatusArray[1...].allSatisfy { $0 }
            checkStatusArray[0] = allSelected
            startButton.toggleEnabledState(allSelected)
        }
        agreementTable.reloadData()
    }
}

extension AgreeToTermsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkStatusArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AgreementCell.id, for: indexPath) as? AgreementCell else {
            return UITableViewCell()
        }
        let type = AgreementType.allCases[indexPath.row]
        cell.configure(with: type)
        let checkStatus = checkStatusArray[indexPath.row]
        cell.checkBox.tag = indexPath.row
        cell.checkBox.isSelected = checkStatus
        cell.checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        cell.didTapTitleHandler = (type == .all) ? nil : { [weak self] in
            guard let self else { return }
            presentFullScreenModalWithNavigation(TermsVC(type: type))
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension AgreeToTermsVC: UITableViewDelegate {
    
}
