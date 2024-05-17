//
//  MyPageView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import SwiftUI

final class MyPageView: UIView{
    var selectedTab: MyPageTabTableViewCell.Tab = .iMake
    var houseScrolledToLast: (() -> Void)?
    var iMakeCalendarScrolledToLast: (() -> Void)?
    var iPickCalendarScrolledToLast: (() -> Void)?
    var didChangeTab: (() -> Void)?
    var didTapBookmark: ((String, Bool) -> Void)?
    var didTapEditProfile: (() -> Void)?
    var didTapNewBuddy: (() -> Void)?
    var didTapBuddy: ((MyPageBuddyTableViewCell.Item.PrivateBuddy) -> Void)?
    var didTapPublicBuddy: ((MyPageBuddyTableViewCell.Item.PublicBuddy) -> Void)?
    var didTapHouse: ((MyPageHouseTainerCollectionViewCell.Item) -> Void)?
    var didTapIMakeCalendar: ((MyPageIMakeSocialCalendarCollectionViewCell.Item) -> Void)?
    var didTapIPickCalendar: ((MyPageIPickSocialCalendarCollectionViewCell.Item) -> Void)?
    var didTapContact: (() -> Void)?
    var didTapContactHouse: (() -> Void)?
    var isOtherUser = false {
        didSet {
            if isOtherUser {
                setNeedsUpdateConstraints()
                navigationView.isHidden = true
                headerView.hideEditButton()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = headerView.systemLayoutSizeFitting(CGSize(width: tableView.frame.width, height: UIView.layoutFittingCompressedSize.height))
        headerView.frame.size = size
        tableView.tableHeaderView = headerView
    }
    
    func updateTable(
        myPage: MyPage
    ){
        headerView.update(with: .init(
            profileRef: myPage.user.profileRef,
            profileName: myPage.user.nickname,
            isEditable: myPage.user.isOwner,
            isHouseTainer: myPage.user.memberType.isHouseTainer,
            inviterNickname: myPage.user.inviterNickname
        ))
        items = [
            .buddies((0..<2).map{ index in
                guard index < myPage.invitations.count else{ return .new }
                let invitation = myPage.invitations[index]
                if myPage.user.isOwner{
                    return .buddy(.init(
                        id: invitation.id,
                        profileURL: invitation.userProfileURL,
                        email: invitation.inviteeEmail,
                        status: invitation.status
                    ))
                }else{
                    return .publicBuddy(.init(
                        id: invitation.id,
                        profileURL: invitation.userProfileURL,
                        profileName: invitation.inviteeEmail
                    ))
                }
            }, mode: myPage.user.isOwner ? .private : .public),
            .houseTainers(MyPageHouseTainerTableViewCell.Item(houseTainers: myPage.houses.map{
                MyPageHouseTainerCollectionViewCell.Item(
                    id: $0.id,
                    mainURL: $0.imageURLs.first,
                    title: $0.title
                )
            }, isHouseTainer: myPage.user.memberType.isHouseTainer)),
            .tab(selectedTab),
            {
                switch selectedTab {
                case .iMake:
                        .iMakeCalendars(MyPageIMakeSocialCalendarTableViewCell.Item(calendars: myPage.events.map{
                            MyPageIMakeSocialCalendarCollectionViewCell.Item(
                                id: $0.id,
                                mainURL: $0.imageURL,
                                badge: $0.scheduleType,
                                title: $0.title,
                                nickname: $0.nickname,
                                isHouseTainer: true,
                                date: $0.updatedAt.format(with: "yy.MM.dd")
                            )
                        }))
                case .iPick:
                        .iPickCalendars(MyPageIPickSocialCalendarTableViewCell.Item(calendars: myPage.bookmarkedEvents.map{
                            MyPageIPickSocialCalendarCollectionViewCell.Item(
                                id: $0.id,
                                mainURL: $0.imageURL,
                                badge: $0.scheduleType,
                                title: $0.title,
                                nickname: $0.nickname,
                                isHouseTainer: true,
                                date: $0.updatedAt.format(with: "yy.MM.dd")
                            )
                        }))
                }
            }(),
            .contact
        ]
        tableView.reloadData()
        
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }
    
    override func updateConstraints() {
        if isOtherUser {
            tableView.snp.updateConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
                make.directionalHorizontalEdges.bottom.equalToSuperview()
            }
        } else {
            navigationView.snp.updateConstraints{
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.directionalHorizontalEdges.equalToSuperview()
            }
            
            titleLabel.snp.updateConstraints{
                $0.directionalVerticalEdges.equalToSuperview().inset(8)
                $0.leading.equalToSuperview().inset(20)
                $0.trailing.lessThanOrEqualToSuperview().inset(20)
            }
            
            tableView.snp.updateConstraints{
                $0.top.equalTo(navigationView.snp.bottom)
                $0.directionalHorizontalEdges.bottom.equalToSuperview()
            }
        }
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let navigationView = {
        let view = UIView()
        return view
    }()
    private let titleLabel = {
        let titleLabel = UILabel()
        titleLabel.text = "MY"
        titleLabel.font = Typo.Heading1()
        titleLabel.textColor = Color.gray900
        return titleLabel
    }()
    private lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Color.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .init(
            origin: .zero,
            size: CGSize(width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude)
        ))
        tableView.register(MyPageBuddyTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageBuddyTableViewCell.self))
        tableView.register(MyPageHouseTainerTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageHouseTainerTableViewCell.self))
        tableView.register(MyPageIMakeSocialCalendarTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageIMakeSocialCalendarTableViewCell.self))
        tableView.register(MyPageIPickSocialCalendarTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageIPickSocialCalendarTableViewCell.self))
        tableView.register(MyPageTabTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageTabTableViewCell.self))
        tableView.register(MyPageContactTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageContactTableViewCell.self))
        return tableView
    }()
    private lazy var headerView = {
        let view = MyPageHeaderView()
        view.didTapEditProfile = { [weak self] in
            guard let self else{ return }
            didTapEditProfile?()
        }
        return view
    }()
    
    // MARK: - Private
    
    private var items: [Item] = []
}

private extension MyPageView{
    func setupUI(){
        addSubview(navigationView)
        navigationView.addSubview(titleLabel)
        addSubview(tableView)
    }
}

extension MyPageView: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = items[section]
        guard let title = item.title else{ return UIView() }
        
        let view = MyPageSectionHeaderTableViewCell()
        view.update(withTitle: title, tooltip: item.description)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let item = items[section]
        guard let _ = item.title else{ return .leastNonzeroMagnitude }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        69
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        184
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
}

extension MyPageView: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.section]{
        case let .buddies(items, mode):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageBuddyTableViewCell.self), for: indexPath) as? MyPageBuddyTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapNew = { [weak self] in
                guard let self else{ return }
                didTapNewBuddy?()
            }
            cell.didTapBuddy = { [weak self] item in
                guard let self else{ return }
                didTapBuddy?(item)
            }
            cell.didTapPublicBuddy = { [weak self] item in
                guard let self else{ return }
                didTapPublicBuddy?(item)
            }
            cell.update(with: items, mode: mode)
            return cell
        case let .houseTainers(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageHouseTainerTableViewCell.self), for: indexPath) as? MyPageHouseTainerTableViewCell else{
                return UITableViewCell()
            }
            if isOtherUser {
                cell.handleNotMypage()
            }
            cell.didTapItem = { [weak self] item in
                guard let self else{ return }
                didTapHouse?(item)
            }
            cell.didTapContact = { [weak self] in
                guard let self else{ return }
                didTapContactHouse?()
            }
            cell.scrolledToLast = { [weak self] in
                guard let self else{ return }
                houseScrolledToLast?()
            }
            cell.update(with: item)
            return cell
        case let .iMakeCalendars(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageIMakeSocialCalendarTableViewCell.self), for: indexPath) as? MyPageIMakeSocialCalendarTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] item in
                guard let self else{ return }
                didTapIMakeCalendar?(item)
            }
            cell.scrolledToLast = { [weak self] in
                guard let self else{ return }
                iMakeCalendarScrolledToLast?()
            }
            cell.update(with: item)
            return cell
        case let .iPickCalendars(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageIPickSocialCalendarTableViewCell.self), for: indexPath) as? MyPageIPickSocialCalendarTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] item in
                guard let self else{ return }
                didTapIPickCalendar?(item)
            }
            cell.scrolledToLast = { [weak self] in
                guard let self else{ return }
                iPickCalendarScrolledToLast?()
            }
            cell.update(with: item)
            return cell
        case let .tab(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageTabTableViewCell.self), for: indexPath) as? MyPageTabTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] tab in
                guard let self else{ return }
                selectedTab = tab
                didChangeTab?()
            }
            cell.update(with: item)
            return cell
        case .contact:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageContactTableViewCell.self), for: indexPath) as? MyPageContactTableViewCell else{
                return UITableViewCell()
            }
            if isOtherUser {
                cell.isHidden = true
                return cell
            } else {
                cell.didTapContact = { [weak self] in
                    guard let self else{ return }
                    didTapContact?()
                }
                cell.update()
                return cell
            }
        }
    }
}

extension MyPageView{
    enum Item{
        case buddies([MyPageBuddyTableViewCell.Item], mode: MyPageBuddyTableViewCell.Mode)
        case houseTainers(MyPageHouseTainerTableViewCell.Item)
        case iMakeCalendars(MyPageIMakeSocialCalendarTableViewCell.Item)
        case iPickCalendars(MyPageIPickSocialCalendarTableViewCell.Item)
        case tab(MyPageTabTableViewCell.Tab)
        case contact
        
        var title: String?{
            switch self{
            case .buddies:
                return "홈버디"
            case .houseTainers:
                return "우리집 소개"
            case .tab:
                return "소셜 스케줄"
            case .iMakeCalendars, .iPickCalendars, .contact:
                return nil
            }
        }
        
        var description: String?{
            switch self{
            case .buddies:
                return "홈버디란? 집초대 모임에 함께 가고 싶은 친구💕"
            case .houseTainers, .iMakeCalendars, .iPickCalendars, .tab, .contact:
                return nil
            }
        }
    }
}

struct MyPageView_Preview: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageView()
        }
    }
}

