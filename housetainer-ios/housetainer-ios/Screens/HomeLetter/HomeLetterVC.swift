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
    private let titleLabel = LabelFactory.build(text: "홈레터", font: Typo.Heading2(), textColor: Color.gray800)
    private let commentsCountLabel = LabelFactory.build(text: "", font: Typo.Heading2(), textColor: Color.purple400)
    
    private lazy var titleView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, commentsCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4.0
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

    init(houseId: String, houseOwnerId: String) {
        self.viewModel = HomeLetterVM(houseId: houseId, houseOwnerId: houseOwnerId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setUI()
        bind()
        setDelegates()
        setupKeyboardDismissGestureRecognizerToScrollView(scrollView)
        setupKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchBlockedMembers()
            await viewModel.fetchComments()
        }
    }
}

extension HomeLetterVC {
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: Icon.arrowLeft, style: .plain, target: self, action: #selector(didTapBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = titleView
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setUI() {
        view.backgroundColor = .white

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
        
        viewModel.isCommentDeleted
            .receive(on: RunLoop.main)
            .sink { [weak self] isCommentDeleted in
                guard let self, let isCommentDeleted else { return }
                view.makeToast(isCommentDeleted ? ToastMessage.deletingCommentSuccess : ToastMessage.deletingCommentFailed , duration: 3.0, position: .center)
                if isCommentDeleted {
                    Task {
                        await self.viewModel.fetchComments()
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isUserBlocked
            .receive(on: RunLoop.main)
            .sink { [weak self] isUserBlocked in
                guard let self, let isUserBlocked else { return }
                if isUserBlocked {
                    view.makeToast(ToastMessage.userBlockingSuccess , duration: 1.5, position: .center) { _ in
                        Task {
                            await self.viewModel.fetchBlockedMembers()
                            await self.viewModel.fetchComments()
                        }
                    }
                } else {
                    view.makeToast(ToastMessage.userBlockingFailed , duration: 1.5, position: .center)
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
    
    private func deleteCommentHandler(_ comment: CommentCellData) {
        Task {
            await viewModel.deleteComment(id: comment.id)
        }
    }

    private func reportCommentHandler(_ comment: CommentCellData) {
        let reportSubject = ReportSubject(reporteeId: comment.writerId, reporteeNickname: comment.nickname, title: comment.content)
        let vc = ReportVC(reportSubject: reportSubject)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
            Task {
                if let writerId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() {
                    let isMyComment = (comment.writerId == writerId)
                    cell.optionButtonTapHandler = { [weak self] in
                        guard let self else { return }
                        var alert = AlertBuilder()
                            .addAction(title: isMyComment ? "삭제하기" : "신고하기", style: .destructive) { [weak self] _ in
                                guard let self else { return }
                                isMyComment ? self.deleteCommentHandler(comment) : self.reportCommentHandler(comment)
                            }

                        if !isMyComment {
                            alert = alert.addAction(title: "차단(글, 댓글)", style: .destructive) { [weak self] _ in
                                guard let self else { return }
                                Task {
                                    await self.viewModel.blockUser(id: comment.writerId)
                                }
                            }
                        }

                        alert = alert.addAction(title: "취소", style: .cancel, handler: nil)
                            .setStyleToActionSheet()

                        let alertController = alert.build()
                        present(alertController, animated: true)
                    }
                    cell.avatarTapHandler = { [weak self] in
                        guard let self else { return }
                        if isMyComment {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                                tabBarController.selectedIndex = 2 // .my 탭의 인덱스
                            }
                        } else {
                            let vc = MyPageVC(userId: comment.writerId)
                            navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
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
