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
    enum Tab: CaseIterable{
        case my
        case pick
        
        var title: String{
            switch self{
            case .my: "MY"
            case .pick: "PICK"
            }
        }
    }
    
    var currentTab: Tab{
        Tab.allCases[tabIndex]
    }
    var houseScrolledToLast: (() -> Void)?
    var calendarScrolledToLast: (() -> Void)?
    var scrolledToLast: (() -> Void)?
    var didChangeTab: (() -> Void)?
    var didTapBookmark: ((String, Bool) -> Void)?
    var didTapEditProfile: (() -> Void)?
    var didTapNewBuddy: (() -> Void)?
    var didTapBuddy: ((MyPageBuddyTableViewCell.Item.PrivateBuddy) -> Void)?
    var didTapPublicBuddy: ((MyPageBuddyTableViewCell.Item.PublicBuddy) -> Void)?
    var didTapHouse: ((MyPageHouseTainerCollectionViewCell.Item) -> Void)?
    var didTapCalendar: ((MyPageCalendarCollectionViewCell.Item) -> Void)?
    var didTapEvent: ((MyPageTabListTableViewCell.Item) -> Void)?
    
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
            profileURL: myPage.user.profileURL,
            profileName: myPage.user.nickname,
            isEditable: myPage.user.isOwner,
            isHouseTainer: myPage.user.memberType.isHouseTainer
        ))
        items = [
            .buddies((myPage.canInvite ? [.new] : []) + myPage.invitations.map{
                if myPage.user.isOwner{
                    return .buddy(.init(id: $0.id, profileURL: $0.userProfileURL, profileName: $0.name, status: $0.status))
                }else{
                    return .publicBuddy(.init(id: $0.id, profileURL: $0.userProfileURL, profileName: $0.name))
                }
            }),
            .houseTainers(MyPageHouseTainerTableViewCell.Item(houseTainers: myPage.houses.map{
                MyPageHouseTainerCollectionViewCell.Item(
                    id: $0.id,
                    mainURL: $0.imageURLs.first,
                    title: $0.title
                )
            })),
            // FIXME: MVP에서 제거 by 기획
            //            .calendars(MyPageCalendarTableViewCell.Item(calendars: myPage.calendars.map{
            //                MyPageCalendarCollectionViewCell.Item(
            //                    mainURL: $0.imageURL,
            //                    badge: $0.scheduleType,
            //                    title: $0.title,
            //                    nickname: $0.nickname,
            //                    date: $0.updatedAt.format(with: "yy.MM.dd")
            //                )
            //            })),
                .tab(MyPageTabTableViewCell.Item(items: Tab.allCases.map{ tab in
                    TabView.Item(
                        title: tab.title
                    )
                }))
        ]
        switch currentTab {
        case .my:
            items += myPage.events.map{
                .tabList(MyPageTabListTableViewCell.Item(
                    id: $0.id,
                    mainURL: $0.imageURL,
                    badge: $0.scheduleType,
                    title: $0.title,
                    nickname: $0.nickname,
                    isHouseTainer: $0.memberType.isHouseTainer,
                    date: $0.updatedAt.format(with: "yy.MM.dd"),
                    isBookmarked: $0.isBookmarked
                ))
            }
        case .pick:
            items += myPage.bookmarkedEvents.map{
                .tabList(MyPageTabListTableViewCell.Item(
                    id: $0.id,
                    mainURL: $0.imageURL,
                    badge: $0.scheduleType,
                    title: $0.title,
                    nickname: $0.nickname,
                    isHouseTainer: $0.memberType.isHouseTainer,
                    date: $0.updatedAt.format(with: "yy.MM.dd"),
                    isBookmarked: $0.isBookmarked
                ))
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - UI Properties
    private lazy var tableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = Color.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MyPageBuddyTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageBuddyTableViewCell.self))
        tableView.register(MyPageHouseTainerTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageHouseTainerTableViewCell.self))
        tableView.register(MyPageCalendarTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageCalendarTableViewCell.self))
        tableView.register(MyPageTabTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageTabTableViewCell.self))
        tableView.register(MyPageTabListTableViewCell.self, forCellReuseIdentifier: String(describing: MyPageTabListTableViewCell.self))
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
    private var tabIndex: Int = 0
}

private extension MyPageView{
    func setupUI(){
        addSubview(tableView)
        
        tableView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}

extension MyPageView: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = items[section]
        guard let title = item.title else{ return nil }
        
        let view = MyPageSectionHeaderTableViewCell()
        view.update(withTitle: title, tooltip: item.description)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch items[indexPath.section]{
        case let .tabList(item):
            didTapEvent?(item)
        case .buddies, .calendars, .houseTainers, .tab:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == max(0, items.count - 1){
            scrolledToLast?()
        }
    }
}

extension MyPageView: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .tabList = items[section]{
            return max(0, items.count - (tableView.numberOfSections - 1))
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.section]{
        case let .buddies(items):
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
            cell.update(with: items)
            return cell
        case let .houseTainers(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageHouseTainerTableViewCell.self), for: indexPath) as? MyPageHouseTainerTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] item in
                guard let self else{ return }
                didTapHouse?(item)
            }
            cell.scrolledToLast = { [weak self] in
                guard let self else{ return }
                houseScrolledToLast?()
            }
            cell.update(with: item)
            return cell
        case let .calendars(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageCalendarTableViewCell.self), for: indexPath) as? MyPageCalendarTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] item in
                guard let self else{ return }
                didTapCalendar?(item)
            }
            cell.scrolledToLast = { [weak self] in
                guard let self else{ return }
                calendarScrolledToLast?()
            }
            cell.update(with: item)
            return cell
        case let .tab(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageTabTableViewCell.self), for: indexPath) as? MyPageTabTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapItem = { [weak self] index in
                guard let self else{ return }
                tabIndex = index
                didChangeTab?()
            }
            cell.update(with: item, selectedIndex: tabIndex)
            return cell
        case let .tabList(item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyPageTabListTableViewCell.self), for: indexPath) as? MyPageTabListTableViewCell else{
                return UITableViewCell()
            }
            cell.didTapBookmark = { [weak self, item] in
                guard let self else{ return }
                didTapBookmark?(item.id, item.isBookmarked)
            }
            cell.update(with: item)
            return cell
        }
    }
}

extension MyPageView{
    enum Item{
        case buddies([MyPageBuddyTableViewCell.Item])
        case houseTainers(MyPageHouseTainerTableViewCell.Item)
        case calendars(MyPageCalendarTableViewCell.Item)
        case tab(MyPageTabTableViewCell.Item)
        case tabList(MyPageTabListTableViewCell.Item)
        
        var title: String?{
            switch self{
            case .buddies:
                return "홈버디"
            case .houseTainers:
                return "하우스테이너 소개"
            case .calendars:
                return "캘린더"
            case .tab, .tabList:
                return nil
            }
        }
        
        var description: String?{
            switch self{
            case .buddies:
                return "홈버디? 집초대 모임에 함께 가고 싶은 친구!💕"
            case .houseTainers, .calendars, .tab, .tabList:
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

