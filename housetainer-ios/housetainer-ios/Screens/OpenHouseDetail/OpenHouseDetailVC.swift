//
//  OpenHouseDetailVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/11/24.
//

import UIKit
import Combine

final class OpenHouseDetailVC: BaseViewController {
    
    private let viewModel: OpenHouseDetailVM
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var subscriptions = Set<AnyCancellable>()
    
    init(id: String) {
        self.viewModel = OpenHouseDetailVM(houseId: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        label.font = Typo.Body3()
        label.textColor = .white
        label.backgroundColor = Color.purple400
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var reportButton: UIImageView = {
        let imageView = UIImageView(image: Icon.edit)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapReportButton)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Heading1())
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        imageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private lazy var housetainerIcon: UIImageView = {
        let imageView = UIImageView(image: Icon.housetainer)
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 11).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        return imageView
    }()
    
    private lazy var nicknameHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatar, nicknameLabel, housetainerIcon])
        stackView.axis = .horizontal
        stackView.spacing = 6.0
        return stackView
    }()
    
    private lazy var mainHouseImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body2(), textColor: Color.gray700)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var homeLetterButton: UIButton = {
        let button = ButtonFactory.buildOutline(config: MyButtonConfig(title: "홈 레터 0", font: Typo.Title4(), textColor: Color.purple400, bgColor: .white), borderColor: Color.purple400)
        button.addTarget(self, action: #selector(didTapHomeLetterButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchHouse()
            await viewModel.fetchHouseCommentsCount()
        }
    }
}

extension OpenHouseDetailVC {
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: Icon.arrowLeft, style: .plain, target: self, action: #selector(didTapBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        let titleView = LabelFactory.build(text: "오픈하우스", font: Typo.Heading2())
        navigationItem.titleView = titleView
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapAvatar() {
        guard let userId = viewModel.house.value?.ownerId else { return }
        let vc = MyPageVC(userId: userId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configure(with house: HouseDetail) {
        mainHouseImage.kf.setImage(with: house.coverImageUrl)
        titleLabel.text = house.title
        categoryLabel.text = house.category?.rawValue ?? HouseCategory.designer.rawValue
        descriptionLabel.text = house.content
        avatar.kf.setImage(with: house.profileUrl, placeholder: Icon.nofaceXS)
        nicknameLabel.text = house.nickname
        if !house.isHousetainer {
            housetainerIcon.isHidden = true
        }
        Task {
            guard let currentUserId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return }
            if house.ownerId == currentUserId {
                await MainActor.run {
                    reportButton.isHidden = true
                }
            }
        }
    }
    
    private func setUI() {
        view.backgroundColor = .white
        
        setupScrollViewAndContentView(scrollView, contentView)

        [categoryLabel, reportButton, titleLabel, nicknameHStack, mainHouseImage, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
        
        view.addSubview(homeLetterButton)
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        reportButton.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-35)
        }

        nicknameHStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.height.equalTo(36)
        }
        
        mainHouseImage.snp.makeConstraints { make in
            make.top.equalTo(nicknameHStack.snp.bottom).offset(24)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            let width = UIScreen.main.bounds.width - 40
            make.width.equalTo(width)
            make.height.equalTo(width * 2 / 3)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainHouseImage.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        homeLetterButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-52)
        }
    }
    
    private func bind() {
        viewModel.house
            .receive(on: RunLoop.main)
            .sink { [weak self] house in
                guard let self, let house else { return }
                configure(with: house)
            }
            .store(in: &subscriptions)
        
        viewModel.houseCommentsCount
            .receive(on: RunLoop.main)
            .sink { [weak self] houseCommentsCount in
                guard let self else { return }
                homeLetterButton.changeAttributedTitle(text: "홈 레터 \(houseCommentsCount)", textColor: Color.purple400)
            }
            .store(in: &subscriptions)
        
        viewModel.isUserBlocked
            .receive(on: RunLoop.main)
            .sink { [weak self] isUserBlocked in
                guard let self, let isUserBlocked else { return }
                if isUserBlocked {
                    view.makeToast(ToastMessage.userBlockingSuccess , duration: 1.5, position: .center) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    view.makeToast(ToastMessage.userBlockingFailed , duration: 1.5, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func didTapHomeLetterButton() {
        guard let houseOwnerId = viewModel.house.value?.ownerId else { return }
        let vc = HomeLetterVC(houseId: viewModel.getHouseId(), houseOwnerId: houseOwnerId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapReportButton() {
        let alert = AlertBuilder()
            .addAction(title: "신고하기", style: .destructive) { [weak self] _ in
                guard let self, let title = titleLabel.text, let ownerId = viewModel.house.value?.ownerId, let reporteeNickname = viewModel.house.value?.nickname else { return }
                let reportSubject = ReportSubject(reporteeId: ownerId, reporteeNickname: reporteeNickname, title: title)
                let vc = ReportVC(reportSubject: reportSubject)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            .addAction(title: "차단(글, 댓글)", style: .destructive) { [weak self] _ in
                guard let self, let id = viewModel.house.value?.ownerId else { return }
                Task {
                    await self.viewModel.blockUser(id: id)
                }
            }
            .addAction(title: "취소", style: .cancel, handler: nil)
            .setStyleToActionSheet()
            .build()
        present(alert, animated: true)
    }
}
