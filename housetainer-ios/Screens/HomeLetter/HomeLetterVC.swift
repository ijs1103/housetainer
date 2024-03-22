//
//  HomeLetterVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/12/24.
//

import UIKit
import Combine

final class HomeLetterVC: UIViewController {
    private let viewModel: HomeLetterVM
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var subscriptions = Set<AnyCancellable>()
    private let icon = UIImageView(image: Icon.arrowLeft)
    private let titleLabel = LabelFactory.build(text: "홈 레터", font: Typo.Heading2())
    private let commentsCountLabel = LabelFactory.build(text: "", font: Typo.Title3(), textColor: Color.purple300)
    
    private lazy var backButtonView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [icon,  titleLabel, commentsCountLabel])
        stackView.setCustomSpacing(8.0, after: icon)
        stackView.axis = .horizontal
        stackView.spacing = 6.0
        return stackView
    }()
    
    private lazy var commentsTable: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.id)
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        let backgroundView = LabelFactory.build(text: Label.emptyComment, font: Typo.Body3(), textColor: Color.gray600)
        tableView.backgroundView = CommentEmptyView()
        tableView.backgroundView?.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private let commentInput = CommentInput(placeholder: Placeholder.comment)

    init(houseId: String) {
        self.viewModel = HomeLetterVM(houseId: houseId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton(with: backButtonView)
        setUI()
        bind()
        setDelegates()
        setupKeyboardDismissGestureRecognizerToScrollView(scrollView)
        setupKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchComments()
        }
    }
}

extension HomeLetterVC {
    private func setUI() {
        
        setupScrollViewAndContentView(scrollView, contentView)
        contentView.addSubview(commentsTable)
        view.addSubview(commentInput)

        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-132)
        }

        commentInput.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] comments in
                guard let self, let comments else { return }
                configureComments(with: comments)
                updateCommentsCount(comments.count)
            }
            .store(in: &subscriptions)
        
        viewModel.isCommentRegistered
            .receive(on: RunLoop.main)
            .sink { [weak self] isCommentRegistered in
                guard let self, let isCommentRegistered else { return }
                view.endEditing(true)
                commentInput.clearText()
                view.makeToast(isCommentRegistered ? ToastMessage.commentRegisteredSuccess : ToastMessage.commentRegisteredFailed, duration: 3.0, position: .center)
                if isCommentRegistered {
                    Task {
                        await self.viewModel.fetchComments()
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isCommentEmpty
            .receive(on: RunLoop.main)
            .sink { [weak self] isCommentEmpty in
                guard let self, let isCommentEmpty else { return }
                if isCommentEmpty {
                    view.endEditing(true)
                    commentInput.clearText()
                    view.makeToast(ToastMessage.emptyHomeLetter, duration: 3.0, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func configureComments(with comments: [CommentCellData]) {
        commentsTable.backgroundView?.isHidden = !comments.isEmpty
        commentsTable.reloadData()
        updateCommentsTableHeight(commentsCount: comments.count)
    }
    
    private func updateCommentsTableHeight(commentsCount: Int) {
        commentsTable.snp.removeConstraints()
        let newHeight = (commentsCount > 0) ? CGFloat(commentsCount * 102) : 95
        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-132)
            make.height.equalTo(newHeight)
        }
        view.layoutIfNeeded()
    }
    
    private func setDelegates() {
        commentInput.delegate = self
    }
    
    private func updateCommentsCount(_ count: Int) {
        commentsCountLabel.text = "\(count)"
    }
}

extension HomeLetterVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

extension HomeLetterVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comments.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.id, for: indexPath) as? CommentCell else { return UITableViewCell() }
        if let comment = viewModel.comments.value?[indexPath.item] {
            cell.configure(with: comment)
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension HomeLetterVC: CommentInputDelegate {
    func didTapRegister(text: String?) {
        guard let text, !text.isEmptyOrWhitespace() else {
            viewModel.isCommentEmpty.send(true)
            return
        }

        Task {
            await viewModel.registerComment(text: text)
        }
    }
}
