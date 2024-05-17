//
//  MyPageVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import Combine

final class MyPageVC: BaseViewController{
    
    private let userId: String?
    
    init(userId: String? = nil){
        self.userId = userId
        self.vm = MyPageVM()
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
            //vm.loadMoreHouses()
        }
        _view.iMakeCalendarScrolledToLast = { [weak self] in
            guard let self else{ return }
            //vm.loadMoreEvents()
        }
        _view.iPickCalendarScrolledToLast = { [weak self] in
            guard let self else{ return }
            //vm.loadMoreBookmarkedEvents()
        }
        _view.didChangeTab = { [weak self] in
            guard let self else{ return }
            vm.changeTab()
        }
        _view.didTapBookmark = { [weak self] id, isBookmarked in
            guard let self else{ return }
            //vm.updateBookmark(eventId: id, isBookmarked: !isBookmarked)
        }
        _view.didTapEditProfile = { [weak self] in
            guard let self else{ return }
            let vc = UpdateProfileVC()
            let navigationVc = UINavigationController(rootViewController: vc)
            navigationVc.modalPresentationStyle = .fullScreen
            navigationController?.present(navigationVc, animated: true)
        }
        _view.didTapNewBuddy = { [weak self] in
            guard let self, (userId == nil) else{ return }
            let vc = InviteUserVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapBuddy = { [weak self] item in
            guard let self else { return }
            Task {
                guard let userId = await NetworkService.shared.fetchMemberId(by: item.email) else { return }
                await MainActor.run {
                    let vc = MyPageVC(userId: userId)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        _view.didTapPublicBuddy = { [weak self] item in
            guard let self else{ return }
            
        }
        _view.didTapContact = { [weak self] in
            guard let self else{ return }
            let vc = AskingVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapHouse = { [weak self] item in
            guard let self else{ return }
            let vc = OpenHouseDetailVC(id: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapIMakeCalendar = { [weak self] item in
            guard let self else{ return }
            let vc = SocialCalendarDetailVC(id: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapIPickCalendar = { [weak self] item in
            guard let self else{ return }
            let vc = SocialCalendarDetailVC(id: item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapContactHouse = { [weak self] in
            guard let self else{ return }
            
            let vc = AskingVC()
            vc.initialTitle = "집 소개 문의"
            navigationController?.pushViewController(vc, animated: true)
        }
        
        _view.isOtherUser = (userId != nil)
        
        vm.myPagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myPage in
                guard let self else{ return }
                _view.updateTable(myPage: myPage)
            }.store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userId != nil {
            setupCustomBackButton()
        } else {
            navigationController?.isNavigationBarHidden = true
        }
        Task {
            let logginedId = await NetworkService.shared.userInfo()?.id.uuidString
            vm.load(userId: self.userId ?? logginedId ?? "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if userId == nil {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    private var vm: MyPageVM
    private lazy var _view = MyPageView()
    
    private var cancellables: [AnyCancellable] = []
}
