//
//  ComplaintVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 3/7/24.
//

import UIKit
import SnapKit
import Combine

final class ReportVC: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let viewModel: ReportVM
    private var subscriptions = Set<AnyCancellable>()
    
    let selectedReportReasonPublisher = CurrentValueSubject<String?, Never>(nil)
    
    private let writerLabel: UILabel = {
        LabelFactory.build(text: Title.writer, font: Typo.Body2(), textColor: Color.gray600)
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body2(), textColor: Color.gray800)
    }()
    
    private let subjectLabel: UILabel = {
        LabelFactory.build(text: Title.subject, font: Typo.Body2(), textColor: Color.gray600)
    }()
    
    private let subjectNameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body2(), textColor: Color.gray800)
    }()
    
    private let subtitleLabel: UILabel = {
        let label = LabelWithPadding(topInset: 16, bottomInset: 18, leftInset: 23, rightInset: 23)
        let style = NSMutableParagraphStyle()
        let lineheight = 20.0
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        label.attributedText = NSAttributedString(
            string: Subtitle.complaint,
            attributes: [
                .paragraphStyle: style
            ])
        label.font = Typo.Body3()
        label.backgroundColor = Color.yellow100
        label.textColor = Color.yellow300
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.numberOfLines = 2
        label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        return label
    }()
    
    private let spacer = Spacer(height: 1)
    
    private let reportReasonLabel: UILabel = {
        LabelFactory.build(text: Title.reportReason, font: Typo.Title3(), textColor: Color.gray800)
    }()
    
    private lazy var checkBoxArray: [CheckBoxInput] = {
        var tempArray: [CheckBoxInput] = []
        Title.checkBoxArray.forEach { title in
            let checkBoxInput = CheckBoxInput(title: title)
            checkBoxInput.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox(_:))))
            checkBoxInput.isUserInteractionEnabled = true
            tempArray.append(checkBoxInput)
        }
        return tempArray
    }()
    
    private lazy var checkBoxStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: checkBoxArray)
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private let contentTextView: MyTextView = {
        let textView = MyTextView()
        textView.placeholder = "추가로 남기실 의견이 있다면 작성해주세요."
        textView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(192)
        }
        return textView
    }()
    
    private let warningView = WarningView()
    
    private lazy var reportButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: "신고하기", font: Typo.Body2(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        return button
    }()
    
    init(reportSubject: ReportSubject) {
        self.viewModel = ReportVM(reporteeId: reportSubject.reporteeId)
        super.init(nibName: nil, bundle: nil)
        configure(with: reportSubject)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bind()
        setupKeyboardDismissGestureRecognizerToScrollView(scrollView)
        setupKeyboardNotification()
    }
}

extension ReportVC {
    
    private func configure(with reportSubject: ReportSubject) {
        subjectNameLabel.text = reportSubject.title
        nicknameLabel.text = reportSubject.reporteeNickname
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollViewAndContentView(scrollView, contentView)
        
        [writerLabel,
         nicknameLabel,
         subjectLabel,
         subjectNameLabel,
         subtitleLabel,
         spacer,
         reportReasonLabel,
         checkBoxStack,
         contentTextView,
         warningView,
         reportButton].forEach {
            contentView.addSubview($0)
        }
        
        writerLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(writerLabel.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(80)
        }
        
        subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(writerLabel.snp.bottom).offset(6)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        subjectNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(subjectLabel.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(80)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(-20)
        }
        
        spacer.snp.makeConstraints { make in
            make.top.equalTo(subjectNameLabel.snp.bottom).offset(14)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        reportReasonLabel.snp.makeConstraints { make in
            make.top.equalTo(spacer.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        checkBoxStack.snp.makeConstraints { make in
            make.top.equalTo(reportReasonLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(checkBoxStack.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        warningView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(28)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(warningView.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-60)
        }
    }
    
    @objc private func didTapReportButton() {
        guard let reportReason = selectedReportReasonPublisher.value, let content = contentTextView.text else { return }
        Task {
            await viewModel.report(reportReason: reportReason, content: content)
        }
    }
    
    private func bind() {
        Publishers
            .CombineLatest(selectedReportReasonPublisher ,contentTextView.textPublisher)
            .receive(on: RunLoop.main)
            .sink { [unowned self] reportReason, content in
                // 신고사유가 선택되고 신고내용이 입력되어야 버튼이 활성화
                guard reportReason != nil else { return }
                if !content.isEmptyOrWhitespace() {
                    reportButton.toggleEnabledState(true)
                } else {
                    reportButton.toggleEnabledState(false)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isReportingSuccess
            .receive(on: RunLoop.main)
            .sink { [unowned self] isReportingSuccess in
                guard let isReportingSuccess else { return }
                if isReportingSuccess {
                    PopUpModalVC.present(initialView: self, type: .reporting, delegate: self)
                } else {
                    view.makeToast(ToastMessage.reportingFailed, duration: 3.0, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
    
    func setupNavigationBar() {
        let customView = UIImageView(image: Icon.close)
        customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClose)))
        customView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        navigationItem.hidesBackButton = true
        let titleView = LabelFactory.build(text: "신고하기", font: Typo.Heading2(), textColor: Color.gray800)
        navigationItem.titleView = titleView
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapCheckBox(_ sender: UITapGestureRecognizer) {
        guard let tappedCheckBox = sender.view as? CheckBoxInput else { return }
        checkBoxArray.forEach { $0.isChecked = false }
        tappedCheckBox.isChecked = true
        selectedReportReasonPublisher.send(tappedCheckBox.getTitle())
    }
}

extension ReportVC: PopUpModalDelegate {
    func didTapOkButton() {
        self.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
