//
//  MyPageVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import Combine

final class MyPageVC: UIViewController{
    
    init(userId: String? = nil){
        vm = MyPageVM(id: userId)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _view.houseScrolledToLast = { [weak self] in
            guard let self else{ return }
            vm.loadMoreHouses()
        }
        _view.calendarScrolledToLast = { [weak self] in
            guard let self else{ return }
            vm.loadMoreCalendars()
        }
        _view.scrolledToLast = { [weak self] in
            guard let self else{ return }
            switch _view.currentTab {
            case .my:
                vm.loadMoreEvents()
            case .pick:
                vm.loadMoreBookmarkedEvents()
            }
        }
        _view.didChangeTab = { [weak self] in
            guard let self else{ return }
            vm.changeTab()
        }
        _view.didTapBookmark = { [weak self] id, isBookmarked in
            guard let self else{ return }
            vm.updateBookmark(eventId: id, isBookmarked: !isBookmarked)
        }
        _view.didTapEditProfile = { [weak self] in
            guard let self else{ return }
            let vc = UpdateProfileVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapNewBuddy = { [weak self] in
            guard let self else{ return }
            let vc = InviteUserVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapBuddy = { [weak self] item in
            guard let self else{ return }
            let vc = MyPageVC(userId: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapPublicBuddy = { [weak self] item in
            guard let self else{ return }
            let vc = MyPageVC(userId: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapEvent = { [weak self] item in
            guard let self else{ return }
            let vc = SocialCalendarDetailVC(id: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapHouse = { [weak self] item in
            guard let self else{ return }
            // TODO: 프론트 미구현
            //            let vc = OpenHouseDetailVC(id: item.id)
            //            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapCalendar = { [weak self] item in
            guard let self else{ return }
            let vc = SocialCalendarDetailVC(id: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        vm.load()
        vm.myPagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myPage in
                guard let self else{ return }
                _view.updateTable(myPage: myPage)
            }.store(in: &cancellables)
    }
    
    private let vm: MyPageVM
    private lazy var _view = MyPageView()
    
    private var cancellables: [AnyCancellable] = []
}
