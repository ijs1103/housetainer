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
    enum SocialCalendarSection: Int {
        case main
    }
    enum OpenHouseSection: Int {
        case main
    }
    private let viewModel = MainVM()
    private var subscriptions = Set<AnyCancellable>()
    private let layout = CenteredCollectionViewFlowLayout()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var alarmButton: UIBarButtonItem!
    private var calendarGridHeightConstraint: Constraint?
    private var houseGridHeightConstraint: Constraint?
    private var contentViewHeightConstraint: Constraint?
    private var socialCalendarDataSource: UICollectionViewDiffableDataSource<SocialCalendarSection, EventDetail>?
    private var socialCalendarSnapshot = NSDiffableDataSourceSnapshot<SocialCalendarSection, EventDetail>()
    private var openHouseDataSource: UICollectionViewDiffableDataSource<OpenHouseSection, House>?
    private var openHouseSnapshot = NSDiffableDataSourceSnapshot<OpenHouseSection, House>()
    private lazy var buttonDictionary: [Category: (button: CategoryButton, fetchFunction: (() -> Void))] = [
        .currentEvents: (currentEventsButton, { Task { await self.viewModel.fetchEvents(isPast: false) } }),
        .pastEvents: (pastEventsButton, { Task { await self.viewModel.fetchEvents(isPast: true) } }),
        .allHouses: (allHousesButton, { Task { await self.viewModel.fetchAllHouses() } }),
        .artistHouses: (artistHousesButton, { Task { await self.viewModel.fetchHouses(by: .artist) } }),
        .creatorHouses: (creatorHousesButton, { Task { await self.viewModel.fetchHouses(by: .creator) } }),
        .designerHouses: (designerHousesButton, { Task { await self.viewModel.fetchHouses(by: .designer) } }),
        .collectorHouses: (collectorHousesButton, { Task { await self.viewModel.fetchHouses(by: .collector) } })
    ]
    
    private let tabMenu = TabMenu()

    private let hLine: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        view.backgroundColor = Color.gray400
        return view
    }()
    
    private lazy var momentHstack: UIStackView = {
        let label = LabelFactory.build(text: Title.moment, font: Typo.Heading3())
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
    
    private lazy var calendarHstack: UIStackView = {
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
    
    private lazy var houseHstack: UIStackView = {
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
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSnapshot()
        setupDataSource()
        setupPickConstraints()
        setDelegates()
        bind()
        NotificationCenter.default.addObserver(self, selector: #selector(handleWhenNeedToUpdate), name: .checkLatestVersion, object: nil)
        Task {
            await viewModel.deleteExpiredInvitations()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchBlockedMembers()
            await fetchPickTabData()
            await viewModel.checkUnreadNotifications()
            let isSignedIn = await NetworkService.shared.isSignedIn()
            if !isSignedIn {
                presentFullScreenModalWithNavigation(SigninVC())
            }
        }
    }
}

extension MainVC {
    private func fetchPickTabData() async {
        await viewModel.fetchEventMoments()
        await viewModel.fetchEventPicks()
        await viewModel.fetchHousePicks()
    }
    
    private func setupNavigationBar() {
        let customView = LabelFactory.build(text: Title.main, font: Typo.Heading1())
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
        alarmButton = UIBarButtonItem(image: Icon.alarmOff?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapAlarmButton))
        navigationItem.rightBarButtonItem = alarmButton
    }
    
    private func updateAlarmButtonImage(to image: UIImage?) {
        alarmButton.image = image?.withRenderingMode(.alwaysOriginal)
    }
    
    private func setupPickConstraints() {
        view.snp.removeConstraints()
                
        setupScrollViewAndContentView(scrollView, contentView)
        
        scrollView.backgroundColor = .white
        
        [tabMenu, hLine].forEach { view.addSubview($0) }
    
        [momentHstack, carousel, calendarHstack, calendarGrid, houseHstack, houseGrid].forEach {
            $0.snp.removeConstraints()
            contentView.addSubview($0)
        }
        
        tabMenu.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        
        hLine.snp.makeConstraints { make in
            make.bottom.equalTo(tabMenu.snp.bottom)
        }
        
        scrollView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)

        momentHstack.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(23)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.height.equalTo(24)
        }
        
        carousel.snp.makeConstraints { make in
            make.top.equalTo(momentHstack.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading)
        }

        calendarHstack.snp.makeConstraints { make in
            make.top.equalTo(carousel.snp.bottom).offset(41)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.height.equalTo(24)
        }
        
        calendarGrid.snp.makeConstraints { make in
            calendarGridHeightConstraint = make.height.equalTo(302).constraint
            make.top.equalTo(calendarHstack.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
        }

        houseHstack.snp.makeConstraints { make in
            make.top.equalTo(calendarGrid.snp.bottom).offset(38)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.height.equalTo(24)
        }
        
        houseGrid.snp.makeConstraints { make in
            houseGridHeightConstraint = make.height.equalTo(238).constraint
            make.top.equalTo(houseHstack.snp.bottom).offset(22)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }
    
    private func setupCalendarConstraints() {
        view.snp.removeConstraints()
        
        [tabMenu, hLine, eventsButtonStack, socialCalendarCollectionView].forEach {
            $0.snp.removeConstraints()
            view.addSubview($0)
        }
        
        tabMenu.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        
        hLine.snp.makeConstraints { make in
            make.bottom.equalTo(tabMenu.snp.bottom)
        }
        
        eventsButtonStack.snp.makeConstraints { make in
            make.top.equalTo(hLine.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(34)
        }
        
        socialCalendarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(eventsButtonStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
        private func setupHouseConstraints() {
            view.snp.removeConstraints()
        
            [tabMenu, hLine, momentHstack, housesButtonStackScrollView, openHouseCollectionView].forEach {
                $0.snp.removeConstraints()
                view.addSubview($0)
            }
 
            tabMenu.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide)
                make.leading.equalTo(view.snp.leading).offset(20)
                make.trailing.equalTo(view.snp.trailing).offset(-20)
            }
    
            hLine.snp.makeConstraints { make in
                make.bottom.equalTo(tabMenu.snp.bottom)
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

            openHouseCollectionView.snp.makeConstraints { make in
                make.top.equalTo(housesButtonStack.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            }
        }
    
    private func setDelegates() {
        carousel.delegate = self
        carousel.dataSource = self
        calendarGrid.delegate = self
        houseGrid.delegate = self
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

    @objc private func didTapCalendarMore() {
        navigationController?.pushViewController(MainTabMenuVC(isSocialCalendarTapped: true), animated: true)
    }
    
    @objc private func didTapHouseMore() {
        let mainTabMenuVC = MainTabMenuVC(isSocialCalendarTapped: false)
        mainTabMenuVC.tapOpenHouseTab()
        navigationController?.pushViewController(mainTabMenuVC, animated: true)
    }

    private func bind() {
        viewModel.eventMoments
            .receive(on: RunLoop.main)
            .sink { [weak self] eventMoments in
                guard let self, eventMoments != nil else { return }
                carousel.reloadData()
            }
            .store(in: &subscriptions)

        viewModel.eventPicks
            .receive(on: RunLoop.main)
            .sink { [weak self] eventPicks in
                guard let self, let eventPicks else { return }
                calendarGrid.configure(with: eventPicks)
                calendarGrid.reloadData()
                let newHeight = eventPicks.count > 2 ? 604 : 302
                self.calendarGridHeightConstraint?.update(offset: newHeight)
            }
            .store(in: &subscriptions)
        
        viewModel.housePicks
            .receive(on: RunLoop.main)
            .sink { [weak self] housePicks in
                guard let self, let housePicks else { return }
                houseGrid.configure(with: housePicks)
                houseGrid.reloadData()
                let newHeight = housePicks.count > 2 ? 476 : 238
                self.houseGridHeightConstraint?.update(offset: newHeight)
            }
            .store(in: &subscriptions)
        
        viewModel.haveUnreadAlarms
            .receive(on: RunLoop.main)
            .sink { [weak self] haveUnreadAlarms in
                guard let self, let haveUnreadAlarms else { return }
                updateAlarmButtonImage(to: haveUnreadAlarms ? Icon.alarmOn : Icon.alarmOff)
            }
            .store(in: &subscriptions)
        
        viewModel.filteredEvents
            .receive(on: RunLoop.main)
            .sink { [unowned self] filteredEvents in
                guard let filteredEvents else { return }
                eventSnapshot(filteredEvents)
                socialCalendarCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.allHouses
            .receive(on: RunLoop.main)
            .sink { [unowned self] allHouses in
                guard let allHouses else { return }
                houseSnapshot(allHouses)
                openHouseCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.filteredHouses
            .receive(on: RunLoop.main)
            .sink { [unowned self] filteredHouses in
                guard let filteredHouses else { return }
                houseSnapshot(filteredHouses)
                openHouseCollectionView.reloadData()
            }.store(in: &subscriptions)
    }
    
    @objc private func didTapAlarmButton() {
        Task {
            await viewModel.readNotifications()
            await MainActor.run {
                navigationController?.pushViewController(AlarmVC(), animated: true)
            }
        }
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
        socialCalendarDataSource = UICollectionViewDiffableDataSource<SocialCalendarSection, EventDetail>(collectionView: socialCalendarCollectionView) { collectionView, indexPath, event in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialCalendarCell.id, for: indexPath) as? SocialCalendarCell else { return UICollectionViewCell() }
            cell.configure(event)
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
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: SpinnerView.id, for: indexPath) as? SpinnerView else { fatalError() }
            footerView.toggleLoading(isEnabled: false)
            return footerView
        }
    }
    
    private func setupSnapshot() {
        socialCalendarSnapshot.appendSections([SocialCalendarSection.main])
        openHouseSnapshot.appendSections([OpenHouseSection.main])
    }
    
    private func calculateCollectionViewHeight(collectionView: UICollectionView, contentCount: Int) -> CGFloat {
        let cellHeight = (collectionView === socialCalendarCollectionView) ? 339 : 425
        return CGFloat(cellHeight * contentCount + 44)
    }

    private func calculateContentViewHeight() -> CGFloat {
        let totalHeight = tabMenu.frame.height + hLine.frame.height + momentHstack.frame.height + carousel.frame.height + calendarHstack.frame.height + calendarGrid.frame.height + houseHstack.frame.height + houseGrid.frame.height + 23 + 23 + 22 + 41 + 22 + 38 + 22 + 20
        return totalHeight
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
    
    private func updateUIForSelectedTab(momentHstackHidden: Bool, carouselHidden: Bool, calendarHstackHidden: Bool, calendarGridHidden: Bool, houseHstackHidden: Bool, houseGridHidden: Bool, socialCalendarCollectionViewHidden: Bool, eventsButtonStackHidden: Bool, openHouseCollectionViewHidden: Bool, housesButtonStackHidden: Bool, housesButtonStackScrollViewHidden: Bool) {
        momentHstack.isHidden = momentHstackHidden
        carousel.isHidden = carouselHidden
        calendarHstack.isHidden = calendarHstackHidden
        calendarGrid.isHidden = calendarGridHidden
        houseHstack.isHidden = houseHstackHidden
        houseGrid.isHidden = houseGridHidden
        socialCalendarCollectionView.isHidden = socialCalendarCollectionViewHidden
        eventsButtonStack.isHidden = eventsButtonStackHidden
        openHouseCollectionView.isHidden = openHouseCollectionViewHidden
        housesButtonStack.isHidden = housesButtonStackHidden
        housesButtonStackScrollView.isHidden = housesButtonStackScrollViewHidden
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
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView === carousel {
            // check if the currentCenteredPage is not the page that was touched
            let currentCenteredPage = layout.currentCenteredPage
            if currentCenteredPage != indexPath.row {
              // trigger a scrollToPage(index: animated:)
                layout.scrollToPage(index: indexPath.row, animated: true)
            }
            
            if let event = viewModel.eventMoments.value?[indexPath.item] {
                let vc = SocialCalendarDetailVC(id: event.id)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        if [socialCalendarCollectionView, openHouseCollectionView].contains(collectionView) {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard [socialCalendarCollectionView, openHouseCollectionView].contains(scrollView),
              let collectionView = scrollView as? UICollectionView else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if contentHeight > height && offsetY > (contentHeight - height - collectionView.contentInset.bottom) && !viewModel.isFetching && viewModel.hasMoreData {
            viewModel.isFetching = true
           
            if let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? SpinnerView {
                footerView.toggleLoading(isEnabled: true)
            }
            
            Task {
                if collectionView === self.socialCalendarCollectionView {
                    switch viewModel.selectedCategory.value {
                    case .currentEvents:
                        await viewModel.fetchMoreEvents(isPast: false)
                    case .pastEvents:
                        await viewModel.fetchMoreEvents(isPast: true)
                    default:
                        break
                    }
                } else if collectionView === self.openHouseCollectionView {
                    switch viewModel.selectedCategory.value {
                    case .allHouses:
                        await viewModel.fetchMoreAllHouses()
                    case .artistHouses:
                        await viewModel.fetchMoreHouses(category: .artist)
                    case .collectorHouses:
                        await viewModel.fetchMoreHouses(category: .collector)
                    case .creatorHouses:
                        await viewModel.fetchMoreHouses(category: .creator)
                    case .designerHouses:
                        await viewModel.fetchMoreHouses(category: .designer)
                    default:
                        break
                    }
                }
                await MainActor.run {
                    if let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? SpinnerView {
                        footerView.toggleLoading(isEnabled: false)
                    }
                    viewModel.isFetching = false
                    collectionView.reloadData()
                }
            }
        }
    }
}

extension MainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.eventMoments.value?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.id, for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        if let mainEvent = viewModel.eventMoments.value?[indexPath.item] {
            cell.configure(mainEvent)
        }
        return cell
    }
}

extension MainVC: TabMenuDelegate {
    func didTapPick() {
        Task {
            await MainActor.run {
                updateUIForSelectedTab(momentHstackHidden: false, carouselHidden: false, calendarHstackHidden: false, calendarGridHidden: false, houseHstackHidden: false, houseGridHidden: false, socialCalendarCollectionViewHidden: true, eventsButtonStackHidden: true, openHouseCollectionViewHidden: true, housesButtonStackHidden: true, housesButtonStackScrollViewHidden: true)
                setupPickConstraints()
            }
            await fetchPickTabData()
            await MainActor.run {
                scrollView.contentSize = CGSize(width: view.frame.width, height: calculateContentViewHeight())
                view.layoutIfNeeded()
            }
        }
    }

    func didTapCalendar() {
        Task {
            await MainActor.run {
                updateUIForSelectedTab(momentHstackHidden: true, carouselHidden: true, calendarHstackHidden: true, calendarGridHidden: true, houseHstackHidden: true, houseGridHidden: true, socialCalendarCollectionViewHidden: false, eventsButtonStackHidden: false, openHouseCollectionViewHidden: true, housesButtonStackHidden: true, housesButtonStackScrollViewHidden: true)
                setupCalendarConstraints()
                allCategoryButtonsDisable()
                currentEventsButton.toggleSelected(true)
                viewModel.selectCategory(.currentEvents)
            }
            await viewModel.fetchEvents(isPast: false)
        }
    }

    func didTapHouse() {
        Task {
            await MainActor.run {
                updateUIForSelectedTab(momentHstackHidden: true, carouselHidden: true, calendarHstackHidden: true, calendarGridHidden: true, houseHstackHidden: true, houseGridHidden: true, socialCalendarCollectionViewHidden: true, eventsButtonStackHidden: true, openHouseCollectionViewHidden: false, housesButtonStackHidden: false, housesButtonStackScrollViewHidden: false)
                setupHouseConstraints()
                housesButtonStackScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                allCategoryButtonsDisable()
                allHousesButton.toggleSelected(true)
                viewModel.selectCategory(.allHouses)
            }
            await viewModel.fetchAllHouses()
        }
    }
}

extension MainVC: CategoryButtonDelegate {
    func didTapCategoryButton(category: Category) {
        viewModel.selectCategory(category)
        for (key, value) in buttonDictionary {
            value.button.toggleSelected(key == category)
            if key == category {
                value.fetchFunction()
            }
        }
        viewModel.hasMoreData = true
    }
}
