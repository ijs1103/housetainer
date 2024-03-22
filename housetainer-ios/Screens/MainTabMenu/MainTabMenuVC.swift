//
//  MainTabMenuVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/1/24.
//

import UIKit
import SnapKit
import Combine

final class MainTabMenuVC: UIViewController {
    private let isSocialCalendarTapped: Bool
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    enum SocialCalendarSection: Int {
        case main
    }
    enum OpenHouseSection: Int {
        case main
    }
    private var socialCalendarDataSource: UICollectionViewDiffableDataSource<SocialCalendarSection, EventDetail>?
    private var socialCalendarSnapshot = NSDiffableDataSourceSnapshot<SocialCalendarSection, EventDetail>()
    private var openHouseDataSource: UICollectionViewDiffableDataSource<OpenHouseSection, House>?
    private var openHouseSnapshot = NSDiffableDataSourceSnapshot<OpenHouseSection, House>()
    private let viewModel = MainTabMenuVM()
    private var subscriptions = Set<AnyCancellable>()
    private var isPaginating = false
    private lazy var buttonDictionary: [Category: (button: CategoryButton, fetchFunction: (() -> Void))] = [
        .currentEvents: (currentEventsButton, { self.viewModel.filterEvents(isPast: false) }),
        .pastEvents: (pastEventsButton, { self.viewModel.filterEvents(isPast: true) }),
        .allHouses: (allHousesButton, { Task { await self.viewModel.fetchAllHouses() } }),
        .artistHouses: (artistHousesButton, { self.viewModel.filterHouses(category: .artist) }),
        .creatorHouses: (creatorHousesButton, { self.viewModel.filterHouses(category: .creator) }),
        .designerHouses: (designerHousesButton, { self.viewModel.filterHouses(category: .designer) }),
        .collectorHouses: (collectorHousesButton, { self.viewModel.filterHouses(category: .collector) })
    ]
    private lazy var tabMenu = TabMenu()

    private lazy var hLine: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        view.backgroundColor = Color.gray400
        return view
    }()
    
    private lazy var currentEventsButton = CategoryButton(category: .currentEvents, isSelected: true)
    private lazy var pastEventsButton = CategoryButton(category: .pastEvents)
    
    private lazy var eventsButtonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentEventsButton, pastEventsButton])
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        return stackView
    }()
    
    private lazy var allHousesButton = CategoryButton(category: .allHouses)
    private lazy var artistHousesButton = CategoryButton(category: .artistHouses)
    private lazy var creatorHousesButton = CategoryButton(category: .creatorHouses)
    private lazy var designerHousesButton = CategoryButton(category: .designerHouses)
    private lazy var collectorHousesButton = CategoryButton(category: .collectorHouses)
    
    private lazy var housesButtonStackScrollView: UIScrollView = {
        let view = UIScrollView()
        view.addSubview(housesButtonStack)
        view.isHidden = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var housesButtonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [allHousesButton, artistHousesButton, creatorHousesButton, designerHousesButton, collectorHousesButton])
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var socialCalendarCollectionView: UICollectionView = {
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionNumber, _ -> NSCollectionLayoutSection? in
            NSCollectionLayoutSection.eventLayout()
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.register(SocialCalendarCell.self, forCellWithReuseIdentifier: SocialCalendarCell.id)
        collectionView.register(
            SpinnerView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SpinnerView.id)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var openHouseCollectionView: UICollectionView = {
        let compositionalLayout = UICollectionViewCompositionalLayout { sectionNumber, _ -> NSCollectionLayoutSection? in
            NSCollectionLayoutSection.houseLayout()
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.register(OpenHouseCell.self, forCellWithReuseIdentifier: OpenHouseCell.id)
        collectionView.register(
            SpinnerView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SpinnerView.id)
        collectionView.isHidden = true
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    init(isSocialCalendarTapped: Bool) {
        self.isSocialCalendarTapped = isSocialCalendarTapped
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupSnapshot()
        setupDataSource()
        setUI()
        setDelegates()
        bind()
        Task {
            if isSocialCalendarTapped {
                await viewModel.fetchAllEvents()
                viewModel.filterEvents(isPast: false)
            } else {
                await viewModel.fetchAllHouses()
            }
        }
    }
}

extension MainTabMenuVC {
    
    private func setUI() {
        setupScrollViewAndContentView(scrollView, contentView)
        
        [tabMenu, hLine, eventsButtonStack, housesButtonStackScrollView, socialCalendarCollectionView, openHouseCollectionView].forEach {
            contentView.addSubview($0)
        }
                
        tabMenu.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(23)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
        
        hLine.snp.makeConstraints { make in
            make.bottom.equalTo(tabMenu.snp.bottom)
        }
        
        eventsButtonStack.snp.makeConstraints { make in
            make.top.equalTo(hLine.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
        }
        
        housesButtonStackScrollView.snp.makeConstraints { make in
            make.top.equalTo(hLine.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(34)
            make.trailing.equalToSuperview().inset(20)
        }
        
        housesButtonStack.snp.makeConstraints { make in
            make.top.equalTo(housesButtonStackScrollView.snp.top)
            make.leading.equalTo(housesButtonStackScrollView.snp.leading)
            make.bottom.equalTo(housesButtonStackScrollView.snp.bottom)
            make.trailing.equalTo(housesButtonStackScrollView.snp.trailing)
            make.height.equalTo(housesButtonStackScrollView.snp.height)
        }
        
        socialCalendarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(eventsButtonStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        openHouseCollectionView.snp.makeConstraints { make in
            make.top.equalTo(eventsButtonStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    private func setDelegates() {
        tabMenu.delegate = self
        socialCalendarCollectionView.delegate = self
        socialCalendarCollectionView.dataSource = socialCalendarDataSource
        openHouseCollectionView.delegate = self
        openHouseCollectionView.dataSource = openHouseDataSource
        currentEventsButton.delegate = self
        pastEventsButton.delegate = self
        allHousesButton.delegate = self
        artistHousesButton.delegate = self
        creatorHousesButton.delegate = self
        designerHousesButton.delegate = self
        collectorHousesButton.delegate = self
    }

    private func eventSnapshot(_ events: [EventDetail]) {
        guard let dataSource = socialCalendarDataSource else { return }
        var snapshot = dataSource.snapshot(for: SocialCalendarSection.main)
        snapshot.deleteAll()
        snapshot.append(events)
        dataSource.apply(snapshot, to: SocialCalendarSection.main)
    }
    
    private func houseSnapshot(_ houses: [House]) {
        guard let dataSource = openHouseDataSource else { return }
        var snapshot = dataSource.snapshot(for: OpenHouseSection.main)
        snapshot.deleteAll()
        snapshot.append(houses)
        dataSource.apply(snapshot, to: OpenHouseSection.main)
    }
    
    private func setupDataSource() {
        socialCalendarDataSource = UICollectionViewDiffableDataSource<SocialCalendarSection, EventDetail>(collectionView: socialCalendarCollectionView) { [weak self] collectionView, indexPath, event in
            guard let self, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialCalendarCell.id, for: indexPath) as? SocialCalendarCell else { return UICollectionViewCell() }
            cell.configure(event)
            cell.delegate = self
            return cell
        }
        openHouseDataSource = UICollectionViewDiffableDataSource<OpenHouseSection, House>(collectionView: openHouseCollectionView) { collectionView, indexPath, house in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenHouseCell.id, for: indexPath) as? OpenHouseCell
            cell?.configure(house)
            return cell ?? UICollectionViewCell()
        }
        setupDataSourceOfFooter(dataSource: socialCalendarDataSource)
        setupDataSourceOfFooter(dataSource: openHouseDataSource)
    }
    
    private func setupDataSourceOfFooter<T, I>(dataSource: UICollectionViewDiffableDataSource<T, I>?) {
        guard let dataSource = dataSource else { return }
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, kind, indexPath) in
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: SpinnerView.id, for: indexPath) as? SpinnerView else { fatalError() }
            footerView.toggleLoading(isEnabled: isPaginating)
            return footerView
        }
    }
    
    private func setupSnapshot() {
        socialCalendarSnapshot.appendSections([SocialCalendarSection.main])
        openHouseSnapshot.appendSections([OpenHouseSection.main])
    }
    
    private func updateCollectionViewHeight(collectionView: UICollectionView, contentCount: Int) {
        [ socialCalendarCollectionView, openHouseCollectionView ].forEach { $0.snp.removeConstraints() }

        let newHeight = calculateContentHeight(collectionView: collectionView, contentCount: contentCount)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(eventsButtonStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(contentView.snp.bottom)
            make.height.equalTo(newHeight)
        }

        view.layoutIfNeeded()
    }
    
    private func calculateContentHeight(collectionView: UICollectionView, contentCount: Int) -> CGFloat {
        let cellHeight = (collectionView === socialCalendarCollectionView) ? 339 : 425
        return CGFloat(cellHeight * contentCount + 44)
    }
    
    private func bind() {
        viewModel.filteredEvents
            .receive(on: RunLoop.main)
            .sink { [unowned self] filteredEvents in
                guard let filteredEvents else { return }
                eventSnapshot(filteredEvents)
                updateCollectionViewHeight(collectionView: socialCalendarCollectionView, contentCount: filteredEvents.count)
            }.store(in: &subscriptions)
        
        viewModel.allHouses
            .receive(on: RunLoop.main)
            .sink { [unowned self] allHouses in
                guard let allHouses else { return }
                houseSnapshot(allHouses)
                updateCollectionViewHeight(collectionView: openHouseCollectionView, contentCount: allHouses.count)
            }.store(in: &subscriptions)
        
        viewModel.filteredHouses
            .receive(on: RunLoop.main)
            .sink { [unowned self] filteredHouses in
                guard let filteredHouses else { return }
                houseSnapshot(filteredHouses)
                updateCollectionViewHeight(collectionView: openHouseCollectionView, contentCount: filteredHouses.count)
            }.store(in: &subscriptions)
    }
    
    private func toggleCollectionViewShowing(isCalendarTapped: Bool) {
        socialCalendarCollectionView.isHidden = !isCalendarTapped
        openHouseCollectionView.isHidden = isCalendarTapped
    }
    
    private func allCategoryButtonsDisable() {
        [
            currentEventsButton,
            pastEventsButton,
            allHousesButton,
            artistHousesButton,
            creatorHousesButton,
            designerHousesButton,
            collectorHousesButton
        ].forEach { $0.toggleSelected(false) }
    }
    
    private func didTapHouseHandler() {
        toggleCollectionViewShowing(isCalendarTapped: false)
        viewModel.selectCategory(.allHouses)
        allCategoryButtonsDisable()
        allHousesButton.toggleSelected(true)
        housesButtonStackScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        eventsButtonStack.isHidden = true
        housesButtonStackScrollView.isHidden = false
        housesButtonStack.isHidden = false
    }
    
    func tapOpenHouseTab() {
        tabMenu.didTapHouseHandler()
        didTapHouseHandler()
    }
}

extension MainTabMenuVC: TabMenuDelegate {
    func didTapCalendar() {
        Task {
            await viewModel.fetchAllEvents()
            viewModel.filterEvents(isPast: false)
            await MainActor.run {
                toggleCollectionViewShowing(isCalendarTapped: true)
                viewModel.selectCategory(.currentEvents)
                allCategoryButtonsDisable()
                currentEventsButton.toggleSelected(true)
                eventsButtonStack.isHidden = false
                housesButtonStackScrollView.isHidden = true
                housesButtonStack.isHidden = true
            }
        }
        
    }
    
    func didTapHouse() {
        Task {
            await viewModel.fetchAllHouses()
            await MainActor.run {
                didTapHouseHandler()
            }
        }
    }
}

extension MainTabMenuVC: CategoryButtonDelegate {
    func didTapCategoryButton(category: Category) {
        viewModel.selectCategory(category)
        for (key, value) in buttonDictionary {
            value.button.toggleSelected(key == category)
            if key == category {
                value.fetchFunction()
            }
        }
    }
}

extension MainTabMenuVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var events: [EventDetail]?
        var houses: [House]?
        switch viewModel.selectedCategory.value {
        case .currentEvents, .pastEvents:
            events = viewModel.filteredEvents.value
        case .allHouses:
            houses = viewModel.allHouses.value
        case .artistHouses, .collectorHouses, .creatorHouses, .designerHouses :
            houses = viewModel.filteredHouses.value
        }
        if let event = events?[indexPath.item] {
            let vc = SocialCalendarDetailVC(id: event.id)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        if let house = houses?[indexPath.row] {
            let vc = OpenHouseDetailVC(id: house.id)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainTabMenuVC: SocialCalendarCellDelegate {
    func didTapLikeButton(event: EventDetail, toggleLikeButtonImage: @escaping () -> Void) {
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
                        toggleLikeButtonImage()
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
