//
//  SocialCalendarDetailVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/26.
//

import UIKit
import SnapKit
import Combine
import Kingfisher

final class SocialCalendarDetailVC: UIViewController {
    
    private let viewModel: SocialCalendarDetailVM
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var subscriptions = Set<AnyCancellable>()
    private lazy var mainImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        return view
    }()
    
    private let scheduleLabel: UILabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body6()
        label.textColor = Color.yellow300
        label.backgroundColor = Color.yellow100
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var likeButton: UIImageView = {
        let view = UIImageView(image: Icon.pickOff)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapLikeButton))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var editButton: UIImageView = {
        let view = UIImageView(image: Icon.edit)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapEditButton))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        view.isHidden = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Title4())
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private let housetainerIcon = UIImageView(image: Icon.housetainer)
    
    private lazy var dateLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500)
    }()
    
    private lazy var subHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nicknameLabel, housetainerIcon])
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        return stackView
    }()
    
    private lazy var subVStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [subHStack, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 2.0
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var nicknameHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatar, subVStack])
        stackView.axis = .horizontal
        stackView.spacing = 6.0
        return stackView
    }()
    
    private lazy var houseImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let houseLabel: UILabel = {
        let label = LabelWithPadding(topInset: 0.0, bottomInset: 0.0, leftInset: 7.0, rightInset: 0.0)
        label.addBorder(side: .left, color: Color.gray300, width: 1.0)
        label.font = Typo.Body3()
        label.textColor = Color.gray700
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, nicknameHStack, houseImage, houseLabel])
        stackView.axis = .vertical
        stackView.setCustomSpacing(12, after: titleLabel)
        stackView.setCustomSpacing(28, after: nicknameHStack)
        stackView.setCustomSpacing(11, after: houseImage)
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body2(), textAlignment: .left)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var relatedLinkLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body2(), textColor: Color.blue200, textAlignment: .left)
        label.isHidden = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRelatedLink))
        label.addGestureRecognizer(gestureRecognizer)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let firstSpacer = Spacer(height: 8)
    
    private let commentLabel: UILabel = {
        LabelFactory.build(text: Label.comment, font: Typo.Title7(), textColor: Color.gray700)
    }()
    
    private let commentCountLabel: UILabel = {
        LabelFactory.build(text: "0", font: Typo.Title5(), textColor: Color.purple300)
    }()
    
    private lazy var commentHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [commentLabel, commentCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        return stackView
    }()
    
    private let secondSpacer = Spacer(height: 1)
    
    private let textLabel: UILabel = {
        let label = LabelFactory.build(text: Label.emptyComment, font: Typo.Body3(), textColor: Color.gray600)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var commentsTable: UITableView = {
        let tableView = UITableView()
        tableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.id)
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        let backgroundView = LabelFactory.build(text: Label.emptyComment, font: Typo.Body3(), textColor: Color.gray600)
        tableView.backgroundView = CommentEmptyView()
        tableView.backgroundView?.isHidden = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let commentInput = CommentInput(placeholder: Placeholder.homeLetter)
    
    init(id: String) {
        self.viewModel = SocialCalendarDetailVM(eventId: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setUI()
        bind()
        setupKeyboardDismissGestureRecognizerToScrollView(scrollView)
        setupKeyboardNotification()
        setDelegates()
        Task {
            await viewModel.fetchEvent()
            await viewModel.fetchHouseByOwnerId()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchEvent()
            await viewModel.fetchComments()
        }
    }
}

extension SocialCalendarDetailVC {
    
    private func configure(with event: EventDetail) {
        mainImage.kf.setImage(with: event.imageUrl)
        avatar.kf.setImage(with: event.profileUrl, placeholder: Icon.nofaceXS)
        scheduleLabel.text = event.scheduleType
        titleLabel.text = event.title
        nicknameLabel.text = event.nickname
        dateLabel.text = event.createdAt
        descriptionLabel.text = event.detail
        Task {
            let isMyEvent = await viewModel.isMyEvent(memberId: event.memberId)
            if isMyEvent {
                editButton.isHidden = false
                likeButton.isHidden = true
            }
            let isLiked = await event.isLiked()
            likeButton.image = isLiked ? Icon.pickOn : Icon.pickOff
        }
        if event.relatedLink != "" {
            relatedLinkLabel.isHidden = false
            relatedLinkLabel.text = event.relatedLink
        }
        if !event.isHousetainer {
            housetainerIcon.isHidden = true
        }
    }
    
    private func configureComments(with comments: [CommentCellData]) {
        commentsTable.backgroundView?.isHidden = !comments.isEmpty
        let commentCount = !comments.isEmpty ? String("+\(comments.count)") : "0"
        commentCountLabel.text = commentCount
        commentsTable.reloadData()
        updateCommentsTableHeight(commentsCount: comments.count)
    }
    
    private func updateCommentsTableHeight(commentsCount: Int) {
        commentsTable.snp.removeConstraints()
        let newHeight = (commentsCount > 0) ? CGFloat(commentsCount * 102) : 95
        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(secondSpacer.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.height.equalTo(newHeight)
        }
        view.layoutIfNeeded()
    }
    
    private func configureHouse(with house: House) {
        houseImage.isHidden = false
        houseLabel.isHidden = false
        houseImage.kf.setImage(with: house.coverImageUrl)
        houseLabel.text = house.title
    }
    
    private func setUI() {
        view.backgroundColor = Color.white
        
        setupScrollViewAndContentView(scrollView, contentView)
        
        [mainImage, scheduleLabel, likeButton, editButton, vStack, descriptionLabel, relatedLinkLabel, firstSpacer, commentHStack, secondSpacer, commentsTable, commentInput].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.width * 2 / 3)
        }
        
        houseImage.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 20 * 2)
            make.height.equalTo(184)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.top).offset(20)
            make.leading.equalTo(mainImage.snp.leading).offset(20)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.top).offset(20)
            make.trailing.equalTo(mainImage.snp.trailing).offset(-20)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.top).offset(20)
            make.trailing.equalTo(mainImage.snp.trailing).offset(-20)
        }
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        housetainerIcon.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(12)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(vStack.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        relatedLinkLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        firstSpacer.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(56)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        commentHStack.snp.makeConstraints { make in
            make.top.equalTo(firstSpacer.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        secondSpacer.snp.makeConstraints { make in
            make.top.equalTo(commentHStack.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(secondSpacer.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        commentInput.snp.makeConstraints { make in
            make.top.equalTo(commentsTable.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    private func bind() {
        viewModel.event
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                guard let self, let event else { return }
                configure(with: event)
            }
            .store(in: &subscriptions)
        
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] comments in
                guard let self, let comments else { return }
                configureComments(with: comments)
            }
            .store(in: &subscriptions)
        
        viewModel.house
            .receive(on: RunLoop.main)
            .sink { [weak self] house in
                guard let self, let house else { return }
                configureHouse(with: house)
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
        
        viewModel.isEventDeleted
            .receive(on: RunLoop.main)
            .sink { [weak self] isEventDeleted in
                guard let self, let isEventDeleted else { return }
                view.makeToast(isEventDeleted ? ToastMessage.eventDeletionSuccess : ToastMessage.eventDeletionFailed, duration: 2.0, position: .center) { _ in
                    if isEventDeleted {
                        self.navigationController?.popViewController(animated: true)
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
                    view.makeToast(ToastMessage.emptyComment, duration: 3.0, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func didTapEditButton( ){
        let alert = AlertBuilder()
            .addAction(title: "수정하기", style: .default) { [weak self] _ in
                guard let self, let event = viewModel.event.value?.response else { return }
                self.navigationController?.pushViewController(UpdateSocialCalendarVC(event: event), animated: true)
            }
            .addAction(title: "삭제하기", style: .default) { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.viewModel.deleteEvent()
                }
            }
            .addAction(title: "닫기", style: .destructive, handler: nil)
            .setStyleToActionSheet()
            .build()
        present(alert, animated: true)
    }
    
    @objc private func didTapRelatedLink() {
        guard let urlString = relatedLinkLabel.text else { return }
        let vc = WebViewController(urlString: urlString)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setDelegates() {
        commentInput.delegate = self
    }
    
    private func toggleLikeButtonImage() {
        likeButton.image = (likeButton.image == Icon.pickOn) ? Icon.pickOff : Icon.pickOn
    }
    
    @objc private func didTapLikeButton() {
        guard let event = viewModel.event.value else { return }
        Task {
            let isLiked = await event.isLiked()
            let alert = AlertBuilder()
                .setTitle(isLiked ? "즐겨찾기에서 삭제하시겠습니까?" : "즐겨찾기에 추가하시겠습니까?")
                .addAction(title: "예", style: .default) { [weak self] _ in
                    guard let self else { return }
                    Task {
                        let eventHostId = event.memberId
                        guard let currentUserId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return }
                        if currentUserId == eventHostId {
                            self.view.makeToast(ToastMessage.addingBookmarkFailed, duration: 3.0, position: .center)
                            return
                        }

                        if isLiked {
                            await NetworkService.shared.deleteEventBookmark(memberId: eventHostId, eventId: event.id)
                            await MainActor.run {
                                self.view.makeToast(ToastMessage.deletingBookmarkSuccess, duration: 3.0, position: .center)
                            }
                        } else {
                            let eventBookmark = EventBookmark(memberId: eventHostId, eventId: event.id, createdAt: Date())
                            await NetworkService.shared.insertEventBookmark(eventBookmark)
                            await MainActor.run {
                                self.view.makeToast(ToastMessage.addingBookmarkSuccess, duration: 3.0, position: .center)
                            }
                        }
                        self.toggleLikeButtonImage()
                    }
                }
                .addAction(title: "아니오", style: .destructive, handler: nil)
                .build()
            await MainActor.run {
                present(alert, animated: true)
            }
        }
    }
}

extension SocialCalendarDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

extension SocialCalendarDetailVC: UITableViewDataSource {
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

extension SocialCalendarDetailVC: CommentInputDelegate {
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
