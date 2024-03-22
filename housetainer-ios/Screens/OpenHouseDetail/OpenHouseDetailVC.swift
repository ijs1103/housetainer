//
//  OpenHouseDetailVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/11/24.
//

import UIKit
import Combine

final class OpenHouseDetailVC: UIViewController {
    
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
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body6()
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Title2())
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
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
    
    private lazy var subTitleLabel: UILabel = {
        let label = LabelFactory.build(text: "House Story", font: Typo.Title2())
        label.textAlignment = .left
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body2())
        label.textAlignment = .left
        label.numberOfLines = 5
        return label
    }()
    
    private lazy var homeLetterButton: UIButton = {
        let button = ButtonFactory.buildOutline(config: MyButtonConfig(title: "홈 레터 0", font: Typo.Title4(), textColor: Color.purple400, bgColor: .white), borderColor: Color.purple400)
        button.addTarget(self, action: #selector(didTapHomeLetterButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
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
    }
    
    private func setUI() {
        
        setupScrollViewAndContentView(scrollView, contentView)

        [categoryLabel, titleLabel, nicknameHStack, mainHouseImage, subTitleLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
        
        view.addSubview(homeLetterButton)
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
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
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainHouseImage.snp.bottom).offset(24)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.greaterThanOrEqualTo(contentView.snp.bottom).offset(-124)
        }
        
        homeLetterButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-52)
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
    }
    
    @objc private func didTapHomeLetterButton() {
        let vc = HomeLetterVC(houseId: viewModel.getHouseId())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
