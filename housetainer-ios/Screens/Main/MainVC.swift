//
//  MainVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/15.
//

import UIKit
import SnapKit
import CenteredCollectionView
import Combine

final class MainVC: UIViewController {
    
    private let viewModel = MainVM()
    private var subscriptions = Set<AnyCancellable>()
    private let layout = CenteredCollectionViewFlowLayout()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    private lazy var eventLabel: UIStackView = {
        let label = LabelFactory.build(text: Title.event, font: Typo.Heading3())
        let image = UIImageView(image: Icon.event)
        let stackView = UIStackView(arrangedSubviews: [label, image])
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()

    private lazy var carousel: UICollectionView = {
        layout.itemSize = CGSize(width: 300, height: 200)
        layout.minimumLineSpacing = 10
        let view = UICollectionView(centeredCollectionViewFlowLayout: layout)
        view.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.id)
        view.showsHorizontalScrollIndicator = false
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var calendarTitle: UIStackView = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().gridSectionTitle(string: Title.socialCalendar)
        let image = UIImageView(image: Icon.calender!)
        let stackView = UIStackView(arrangedSubviews: [label, image])
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    private let calendarGrid = EventGrid()
    
    private lazy var calendarMoreButton: UIButton = {
        let button = ButtonFactory.buildOutline(config: MyButtonConfig(title: Title.more, font: Typo.Title4(), textColor: .black, bgColor: .white), borderColor: Color.gray300)
        button.addTarget(self, action: #selector(didTapCalendarMore), for: .touchUpInside)
        return button
    }()
    
    private lazy var houseTitle: UIStackView = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().gridSectionTitle(string: Title.openHouse)
        let image = UIImageView(image: Icon.house!)
        let stackView = UIStackView(arrangedSubviews: [label, image])
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    private let houseGrid = HouseGrid()

    private lazy var houseMoreButton: UIButton = {
        let button = ButtonFactory.buildOutline(config: MyButtonConfig(title: Title.more, font: Typo.Title4(), textColor: .black, bgColor: .white), borderColor: Color.gray300)
        button.addTarget(self, action: #selector(didTapHouseMore), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        setUI()
        setDelegates()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let isSignedIn = await NetworkService.shared.isSignedIn()
            if !isSignedIn {
                presentFullScreenModalWithNavigation(SigninVC())
            }
        }
    }
}

extension MainVC {
    private func fetchAll() {
        Task {
            await viewModel.fetchMainEvents()
            await viewModel.fetchRecentCalendars()
            await viewModel.fetchRecentHouses()
        }
    }
    
    private func setNavi() {
        let customView = LabelFactory.build(text: Title.main, font: Typo.Heading1())
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(didTapHamburgerMenu))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func setUI() {
        
        setupScrollViewAndContentView(scrollView, contentView)
        
        [eventLabel, carousel, calendarTitle, calendarGrid, calendarMoreButton, houseTitle, houseGrid, houseMoreButton].forEach {
            contentView.addSubview($0)
        }

        eventLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(23)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        carousel.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading)
        }

        calendarTitle.snp.makeConstraints { make in
            make.top.equalTo(carousel.snp.bottom).offset(41)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        calendarGrid.snp.makeConstraints { make in
            make.height.equalTo(604)
            make.top.equalTo(calendarTitle.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        calendarMoreButton.snp.makeConstraints { make in
            make.top.equalTo(calendarGrid.snp.bottom).offset(2)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        houseTitle.snp.makeConstraints { make in
            make.top.equalTo(calendarMoreButton.snp.bottom).offset(38)
            make.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        houseGrid.snp.makeConstraints { make in
            make.height.equalTo(476)
            make.top.equalTo(houseTitle.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }
        
        houseMoreButton.snp.makeConstraints { make in
            make.top.equalTo(houseGrid.snp.bottom)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }

    }
    
    private func setDelegates() {
        carousel.delegate = self
        carousel.dataSource = self
        calendarGrid.delegate = self
        houseGrid.delegate = self
    }

    @objc private func didTapCalendarMore() {
        navigationController?.pushViewController(MainTabMenuVC(isSocialCalendarTapped: true), animated: true)
    }
    
    @objc private func didTapHouseMore() {
        let mainTabMenuVC = MainTabMenuVC(isSocialCalendarTapped: false)
        mainTabMenuVC.tapOpenHouseTab()
        navigationController?.pushViewController(mainTabMenuVC, animated: true)
    }
    
    @objc private func didTapHamburgerMenu() {
        let alert = AlertBuilder()
            .addAction(title: "신고하기", style: .default) { [weak self] _ in
                guard let self else { return }
                let vc = ComplaintVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            .addAction(title: "문의하기", style: .default) { [weak self] _ in
                guard let self else { return }
                let vc = AskingVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
            .addAction(title: "회원탈퇴", style: .default) { [weak self] _ in
                guard let self else { return }
                handleWithDrawal()
                
            }
            .addAction(title: "로그아웃", style: .default) { [weak self] _ in
                guard let self else { return }
                handleSignOut()
            }
            .addAction(title: "닫기", style: .destructive, handler: nil)
            .setStyleToActionSheet()
            .build()
        present(alert, animated: true)
    }
    
    private func bind() {
        viewModel.mainEvents
            .receive(on: RunLoop.main)
            .sink { [weak self] mainEvents in
                guard let self, mainEvents != nil else { return }
                carousel.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.recentCalendars
            .receive(on: RunLoop.main)
            .sink { [weak self] recentCalendars in
                guard let self, let recentCalendars else { return }
                calendarGrid.configure(with: recentCalendars)
                calendarGrid.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.recentHouses
            .receive(on: RunLoop.main)
            .sink { [weak self] recentHouses in
                guard let self, let recentHouses else { return }
                houseGrid.configure(with: recentHouses)
                houseGrid.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    private func handleWithDrawal() {
        let alert = AlertBuilder()
            .setTitle("회원탈퇴")
            .setMessage("하우스테이너 회원에서 탈퇴하시겠습니까? 등록하신 정보와 댓글들은 전부 삭제되며 소식을 더 이상 받아보실 수 없습니다.")
            .addAction(title: "취소", style: .destructive, handler: nil)
            .addAction(title: "확인", style: .default) { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.viewModel.withDrawal()
                    self.viewModel.kakaoNaverSignOut()
                    NetworkService.shared.supabaseSignOut()
                    await MainActor.run {
                        self.presentFullScreenModalWithNavigation(SigninVC())
                    }
                }
            }
            .build()
        present(alert, animated: true)
    }
    
    private func handleSignOut() {
        viewModel.kakaoNaverSignOut()
        NetworkService.shared.supabaseSignOut()
        presentFullScreenModalWithNavigation(SigninVC())
    }
}

extension MainVC: EventGridDelegate {
    func didTapGridCell(event: EventWithNickname) {
        let vc = SocialCalendarDetailVC(id: event.id)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainVC: HouseGridDelegate {
    func didTapGridCell(house: HouseWithNickname) {
        let vc = OpenHouseDetailVC(id: house.id)
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if the currentCenteredPage is not the page that was touched
        let currentCenteredPage = layout.currentCenteredPage
        if currentCenteredPage != indexPath.row {
          // trigger a scrollToPage(index: animated:)
            layout.scrollToPage(index: indexPath.row, animated: true)
        }
        
        if let event = viewModel.mainEvents.value?[indexPath.item] {
            let vc = SocialCalendarDetailVC(id: event.id)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.mainEvents.value?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.id, for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        if let mainEvent = viewModel.mainEvents.value?[indexPath.item] {
            cell.configure(mainEvent)
        }
        return cell
    }
}
