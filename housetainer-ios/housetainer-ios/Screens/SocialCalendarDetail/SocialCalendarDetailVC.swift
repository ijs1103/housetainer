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
        view.contentMode = .scaleToFill
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        label.font = Typo.Body3()
        label.textColor = .white
        label.backgroundColor = Color.purple400
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.text = "Host"
        return label
    }()
    
    private let dateLabel = LabelFactory.build(text: "", font: Typo.Body2(), textColor: Color.gray700)
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Heading1(), textColor: Color.gray900)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private let housetainerIcon = UIImageView(image: Icon.housetainer)

    private lazy var nicknameHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatar, nicknameLabel, housetainerIcon])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.setCustomSpacing(8, after: avatar)
        stackView.setCustomSpacing(2, after: nicknameLabel)
        return stackView
    }()
    
    private let firstSpacer = Spacer(height: 1)
    
    private let descriptionLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body2(), textAlignment: .left)
        label.numberOfLines = 0
        return label
    }()
    
    private let relatedLinkView = RelatedLinkView()
    
    private let openHouseLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString()
        let nickNameAttributes: [NSAttributedString.Key: Any] = [.font: Typo.Body2(), .foregroundColor: Color.purple400]
        attributedString.append(NSAttributedString(string: "", attributes: nickNameAttributes))
        let wonderingAttributes: [NSAttributedString.Key: Any] = [.font: Typo.Body2(), .foregroundColor: UIColor.black]
        attributedString.append(NSAttributedString(string: Title.wondering, attributes: wonderingAttributes))
        label.attributedText = attributedString
        label.isHidden = true
        return label
    }()
    
    private lazy var houseImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.gray300
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10.0
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHouseImage)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let houseTitleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body1(), textColor: .white)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    private let secondSpacer = Spacer(height: 1)
        
    private let commentLabel = LabelFactory.build(text: Label.comment, font: Typo.Title7(), textColor: Color.gray700)
    
    private let commentCountLabel = LabelFactory.build(text: "0", font: Typo.Title5(), textColor: Color.purple300)
    
    private lazy var commentHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [commentLabel, commentCountLabel])
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
        tableView.backgroundView?.isHidden = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let commentInput = CommentInput(placeholder: Placeholder.comment)
    
    init(id: String) {
        self.viewModel = SocialCalendarDetailVM(eventId: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftBarButton()
        setUI()
        bind()
        setupKeyboardDismissGestureRecognizerToScrollView(scrollView)
        setupKeyboardNotification()
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchEvent()
            await viewModel.fetchHouseByOwnerId()
            await viewModel.fetchBlockedMembers()
            await viewModel.fetchComments()
            _ = await NetworkService.shared.fetchEventBookMarks(eventId: viewModel.getEventId())
        }
    }
}

extension SocialCalendarDetailVC {
    private func setupLeftBarButton() {
        let backButton = UIBarButtonItem(image: Icon.arrowLeft, style: .plain, target: self, action: #selector(didTapBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupRightBarButton(event: EventDetail) async {
        let isMyEvent = await viewModel.isMyEvent(memberId: event.memberId)
        let isLiked = await event.isLiked()
        if isMyEvent {
            setupEditButtons()
        } else {
            setupBookMarkAndReportButton(isLiked: isLiked)
        }
    }

    @MainActor
    private func setupEditButtons() {
        let editButton = UIBarButtonItem(image: Icon.edit, style: .plain, target: self, action: #selector(didTapEditButton))
        editButton.tintColor = .black
        navigationItem.rightBarButtonItem = editButton
    }
    
    @MainActor
    private func setupBookMarkAndReportButton(isLiked: Bool) {
        let reportButton = UIBarButtonItem(image: Icon.edit, style: .plain, target: self, action: #selector(didTapReportButton))
        let bookMarkButton = UIBarButtonItem(image: isLiked ? Icon.bookMarkActive : Icon.bookMarkInactive, style: .plain, target: self, action: #selector(didTapBookMarkButton))
        reportButton.tintColor = .black
        bookMarkButton.tintColor = .black
        navigationItem.rightBarButtonItems = [reportButton, bookMarkButton]
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapReportButton() {
        let alert = AlertBuilder()
            .addAction(title: "신고하기", style: .destructive) { [weak self] _ in
                guard let self, let title = titleLabel.text, let reporteeId = viewModel.event.value?.memberId, let reporteeNickname = viewModel.event.value?.nickname else { return }
                let reportSubject = ReportSubject(reporteeId: reporteeId, reporteeNickname: reporteeNickname, title: title)
                let vc = ReportVC(reportSubject: reportSubject)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            .addAction(title: "차단(글, 댓글)", style: .destructive) { [weak self] _ in
                guard let self, let id = viewModel.event.value?.memberId else { return }
                Task {
                    await self.viewModel.blockUser(id: id, blockType: .post)
                }
            }
            .addAction(title: "취소", style: .cancel, handler: nil)
            .setStyleToActionSheet()
            .build()
        present(alert, animated: true)
    }
    
    @objc private func didTapAvatar() {
        guard let userId = viewModel.event.value?.memberId else { return }
        let vc = MyPageVC(userId: userId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureEvent(with event: EventDetail) {
        Task {
            await setupRightBarButton(event: event)
        }
        mainImage.kf.setImage(with: event.imageUrl, completionHandler: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                let width = value.image.size.width
                let height = value.image.size.height
                if width >= height {
                    self.mainImage.snp.makeConstraints { make in
                        make.height.equalTo(UIScreen.main.bounds.width * 2 / 3)
                    }
                    view.layoutIfNeeded()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        avatar.kf.setImage(with: event.profileUrl, placeholder: Icon.nofaceXS)
        titleLabel.text = event.title
        nicknameLabel.text = event.nickname
        dateLabel.text = event.date
        descriptionLabel.text = event.detail
        categoryLabel.text = event.scheduleType
        updateNickNameText(with: event.nickname)
        if event.relatedLink != "" {
            relatedLinkView.setUrl(event.relatedLink)
        } else {
            relatedLinkView.isHidden = true
        }
        if !event.isHousetainer {
            housetainerIcon.isHidden = true
        }
    }
    
    private func configureComments(with comments: [CommentCellData]) {
        commentsTable.backgroundView?.isHidden = !comments.isEmpty
        let commentCount = !comments.isEmpty ? "\(comments.count)" : "0"
        commentCountLabel.text = commentCount
        commentsTable.reloadData()
        updateCommentsTableHeight(commentsCount: comments.count)
    }
    
    private func updateCommentsTableHeight(commentsCount: Int) {
        commentsTable.snp.removeConstraints()
        let newHeight = (commentsCount > 0) ? CGFloat(commentsCount * 102) : 95
        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(commentHStack.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.height.equalTo(newHeight)
        }
        view.layoutIfNeeded()
    }
    
    private func configureHouse(with house: House) {
        updateHouseConstraints()
        openHouseLabel.isHidden = false
        houseImage.isHidden = false
        houseTitleLabel.isHidden = false
        houseImage.kf.setImage(with: house.coverImageUrl)
        houseTitleLabel.text = house.title
    }
    
    private func updateHouseConstraints() {
        [openHouseLabel, houseImage, houseTitleLabel, secondSpacer].forEach {
            $0.snp.removeConstraints()
        }
        
        openHouseLabel.snp.makeConstraints { make in
            make.top.equalTo(relatedLinkView.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        houseImage.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width - 20 * 2)
            make.height.equalTo(204)
            make.top.equalTo(openHouseLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        houseTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(houseImage.snp.bottom).offset(-20)
            make.leading.equalTo(houseImage.snp.leading).offset(20)
        }
        
        secondSpacer.snp.makeConstraints { make in
            make.top.equalTo(houseImage.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        view.layoutIfNeeded()
    }
    
    private func setUI() {
        view.backgroundColor = Color.white
        
        setupScrollViewAndContentView(scrollView, contentView)
        
        [mainImage, categoryLabel, dateLabel, titleLabel, nicknameHStack, firstSpacer, descriptionLabel, relatedLinkView, openHouseLabel, houseImage, houseTitleLabel, secondSpacer, commentHStack, commentsTable, commentInput].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.width * 3 / 2)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.top).offset(16)
            make.leading.equalTo(mainImage.snp.leading).offset(16)
        }
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        housetainerIcon.snp.makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        nicknameHStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        firstSpacer.snp.makeConstraints { make in
            make.top.equalTo(nicknameHStack.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(firstSpacer.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        relatedLinkView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }

        secondSpacer.snp.makeConstraints { make in
            make.top.equalTo(relatedLinkView.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
        }
        
        commentHStack.snp.makeConstraints { make in
            make.top.equalTo(secondSpacer.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        commentsTable.snp.makeConstraints { make in
            make.top.equalTo(commentHStack.snp.bottom).offset(20)
            make.leading.equalTo(contentView.snp.leading).offset(20)
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
                configureEvent(with: event)
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
                view.makeToast(isCommentRegistered ? ToastMessage.commentRegisteredSuccess : ToastMessage.commentRegisteredFailed, duration: 2.0, position: .center)
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
                    view.makeToast(ToastMessage.emptyComment, duration: 2.0, position: .center)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isCommentDeleted
            .receive(on: RunLoop.main)
            .sink { [weak self] isCommentDeleted in
                guard let self, let isCommentDeleted else { return }
                view.makeToast(isCommentDeleted ? ToastMessage.deletingCommentSuccess : ToastMessage.deletingCommentFailed , duration: 2.0, position: .center)
                if isCommentDeleted {
                    Task {
                        await self.viewModel.fetchComments()
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isUserBlocked
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self, let isUserBlocked = data?.0, let blockType = data?.1 else { return }
                if isUserBlocked {
                    view.makeToast(ToastMessage.userBlockingSuccess , duration: 1.5, position: .center) { _ in
                        switch blockType {
                        case .post:
                            self.navigationController?.popViewController(animated: true)
                        case .comment:
                            Task {
                                await self.viewModel.fetchBlockedMembers()
                                await self.viewModel.fetchComments()
                            }
                        }
                    }
                } else {
                    view.makeToast(ToastMessage.userBlockingFailed , duration: 1.5, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func didTapEditButton(){
        let alertBuilder = AlertBuilder()
            .addAction(title: "삭제하기", style: .destructive) { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.viewModel.deleteEvent()
                }
            }
            .addAction(title: "취소", style: .cancel, handler: nil)
            .setStyleToActionSheet()
        
        if let isPast = viewModel.event.value?.isPast, !isPast {
            alertBuilder.addAction(title: "수정하기", style: .default) { [weak self] _ in
                guard let self, let event = viewModel.event.value?.response else { return }
                self.navigationController?.pushViewController(UpdateSocialCalendarVC(event: event), animated: true)
            }
        }
        
        let alert = alertBuilder.build()
        present(alert, animated: true)
    }
    
    
    private func setDelegates() {
        commentInput.delegate = self
        relatedLinkView.delegate = self
    }
    
    @objc private func didTapBookMarkButton() {
        guard let event = viewModel.event.value else { return }
        Task {
            let isLiked = await event.isLiked()
            let alert = AlertBuilder()
                .setTitle(isLiked ? "즐겨찾기에서 삭제하시겠습니까?" : "즐겨찾기에 추가하시겠습니까?")
                .addAction(title: "예", style: .default) { [weak self] _ in
                    guard let self else { return }
                    Task {
                        let eventOwnerId = event.memberId
                        guard let currentUserId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return }
                        if currentUserId == eventOwnerId {
                            self.view.makeToast(ToastMessage.addingBookmarkFailed, duration: 3.0, position: .center)
                            return
                        }

                        if isLiked {
                            await NetworkService.shared.deleteEventBookmark(memberId: currentUserId, eventId: event.id)
                            await MainActor.run {
                                self.view.makeToast(ToastMessage.deletingBookmarkSuccess, duration: 3.0, position: .center)
                            }
                        } else {
                            let eventBookmark = EventBookmark(memberId: currentUserId, eventId: event.id, createdAt: Date())
                            await NetworkService.shared.insertEventBookmark(eventBookmark, eventOwnerId: eventOwnerId)
                            await MainActor.run {
                                self.view.makeToast(ToastMessage.addingBookmarkSuccess, duration: 3.0, position: .center)
                            }
                        }
                        self.setupBookMarkAndReportButton(isLiked: !isLiked)
                    }
                }
                .addAction(title: "아니오", style: .destructive, handler: nil)
                .build()
            await MainActor.run {
                present(alert, animated: true)
            }
        }
    }
    
    func updateNickNameText(with text: String) {
        let nickNameAttributes: [NSAttributedString.Key: Any] = [.font: Typo.Body2(), .foregroundColor: Color.purple400]
        let attributedString = NSMutableAttributedString(string: text, attributes: nickNameAttributes)
        let wonderingAttributes: [NSAttributedString.Key: Any] = [.font: Typo.Body2(), .foregroundColor: UIColor.black]
        attributedString.append(NSAttributedString(string: Title.wondering, attributes: wonderingAttributes))
        openHouseLabel.attributedText = attributedString
    }
    
    @objc private func didTapHouseImage() {
        guard let houseId = viewModel.house.value?.id else { return }
        let vc = OpenHouseDetailVC(id: houseId)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
                                    await self.viewModel.blockUser(id: comment.writerId, blockType: .comment)
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

extension SocialCalendarDetailVC: RelatedLinkViewDelegate {
    func didTapRelatedLink() {
        guard let urlString = relatedLinkView.urlText() else { return }
        let vc = WebViewController(urlString: urlString)
        navigationController?.pushViewController(vc, animated: true)
    }
}
