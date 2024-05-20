//
//  MyPageVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import Combine
import Supabase
import Combine

extension NSNotification.Name{
    static let eventBookmarkChanged = Self(rawValue: "eventBookmarkChanged")
}

extension MyPageVM{
    static let userInfoKey = "model"
}

@MainActor
final class MyPageVM{
    init(repository: MyPageRepository = MyPageRepositoryImpl()) {
        self.id = nil
        self.repository = repository
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateNickname(_:)), name: .nicknameUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateProfile(_:)), name: .profileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateSocialCalendar(_:)), name: .socialCalendarCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeEventBookmark(_:)), name: .eventBookmarkChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didInviteUser(_:)), name: .userInvited, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Internal
    var myPagePublisher: AnyPublisher<MyPage, Never>{
        myPageSubject
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }
    
    func changeTab(){
        guard let oldValue = myPageSubject.value else{ return }
        myPageSubject.send(oldValue)
    }
    
    func load(userId: String) {
        cancellables.removeAll(keepingCapacity: true)
        loading = .all
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading = [] }
            self.id = userId
            do{
                let myPage = try await repository.requestMyPage(by: id)
                myPageSubject.send(myPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    func loadMoreHouses() {
        guard !loading.contains(.house) else{ return }
        
        loading.insert(.house)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.house) }
            
            guard let oldMyPage = myPageSubject.value, let lastHouse = oldMyPage.houses.last else{ return }
            do{
                let newHouses = try await repository.requestMyPageHouses(by: id, cursor: lastHouse.id)
                let newMyPage = oldMyPage.copy(houses: oldMyPage.houses + newHouses)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    func loadMoreCalendars() {
        guard !loading.contains(.calendar) else{ return }
        
        loading.insert(.calendar)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.calendar) }
            
            guard let oldMyPage = myPageSubject.value, let lastCalendar = oldMyPage.calendars.last else{ return }
            do{
                let newCalendars = try await repository.requestCalendars(by: id, cursor: lastCalendar.id)
                let newMyPage = oldMyPage.copy(calendars: oldMyPage.calendars + newCalendars)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    func loadMoreEvents() {
        guard !loading.contains(.event) else{ return }
        
        loading.insert(.event)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.event) }
            
            guard let oldMyPage = myPageSubject.value, let lastEvent = oldMyPage.events.last else{ return }
            do{
                let newEvents = try await repository.requestMyPageEvents(by: id, cursor: lastEvent.id)
                let newMyPage = oldMyPage.copy(events: oldMyPage.events + newEvents)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    func loadMoreBookmarkedEvents() {
        guard !loading.contains(.bookmarkedEvent) else{ return }
        
        loading.insert(.bookmarkedEvent)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.bookmarkedEvent) }
            
            guard let oldMyPage = myPageSubject.value, let lastBookmarkedEvent = oldMyPage.bookmarkedEvents.last else{ return }
            do{
                let newBookmarkedEvents = try await repository.requestMyPageBookmarkedEvents(by: id, cursor: lastBookmarkedEvent.id)
                let newMyPage = oldMyPage.copy(bookmarkedEvents: oldMyPage.bookmarkedEvents + newBookmarkedEvents)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    func updateBookmark(eventId: String, isBookmarked: Bool) {
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
          
            guard let oldMyPage = myPageSubject.value else{ return }
            let newMyPage = oldMyPage.copy(bookmarkedEvents: oldMyPage.bookmarkedEvents.map{ event in
                guard event.id == eventId else{ return event }
                var newEvent = event
                newEvent.isBookmarked = isBookmarked
                return newEvent
            })
            myPageSubject.send(newMyPage)
            
            do{
                try await repository.requestBookmarkEvent(by: id, id: eventId, isBookmarked: isBookmarked)
                NotificationCenter.default.post(name: .eventBookmarkChanged, object: self, userInfo: [
                    MyPageVM.userInfoKey: newMyPage
                ])
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Private
    private var id: String?
    private let myPageSubject = CurrentValueSubject<MyPage?, Never>(nil)
    private let repository: MyPageRepository
    private var cancellables: [AnyCancellable] = []
    private var loading: Loading = []
    
    @objc private func didUpdateNickname(_ notification: NSNotification){
        guard let oldMyPage = myPageSubject.value, let model = notification.userInfo?[UpdateNicknameVM.userInfoKey] as? UserNickname else{ return }
        let newMyPage = oldMyPage.copy(
            user: MyPageUser(
                id: oldMyPage.user.id,
                profileRef: oldMyPage.user.profileRef,
                nickname: oldMyPage.user.nickname,
                memberType: oldMyPage.user.memberType,
                isOwner: oldMyPage.user.isOwner, inviterNickname: oldMyPage.user.inviterNickname
            )
        )
        myPageSubject.send(newMyPage)
    }
    
    @objc private func didUpdateProfile(_ notification: NSNotification){
        guard let oldMyPage = myPageSubject.value, let model = notification.userInfo?[UpdateProfileVM.userInfoKey] as? UserProfile else{ return }
        let newMyPage = oldMyPage.copy(
            user: MyPageUser(
                id: oldMyPage.user.id,
                profileRef: model.profileRef,
                nickname: model.username,
                memberType: model.memberType,
                isOwner: oldMyPage.user.isOwner, inviterNickname: oldMyPage.user.inviterNickname
            )
        )
        myPageSubject.send(newMyPage)
    }
    
    @objc private func didCreateSocialCalendar(_ notification: NSNotification){
        guard !loading.contains(.event) else{ return }
        
        loading.insert(.event)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.event) }
            
            guard let oldMyPage = myPageSubject.value else{ return }
            do{
                let newEvents = try await repository.requestMyPageEvents(by: id, cursor: nil)
                let newMyPage = oldMyPage.copy(events: newEvents)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    @objc private func didChangeEventBookmark(_ notification: NSNotification){
        guard !loading.contains(.bookmarkedEvent) else{ return }
        
        loading.insert(.bookmarkedEvent)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.bookmarkedEvent) }
            
            guard let oldMyPage = myPageSubject.value else{ return }
            do{
                let newEvents = try await repository.requestMyPageBookmarkedEvents(by: id, cursor: nil)
                let newMyPage = oldMyPage.copy(bookmarkedEvents: newEvents)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    @objc private func didInviteUser(_ notification: NSNotification){
        guard !loading.contains(.invitations) else{ return }
        
        loading.insert(.invitations)
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading.remove(.invitations) }
            
            guard let oldMyPage = myPageSubject.value else{ return }
            do{
                let newInvitations = try await repository.requestMyPageInvitations(by: id)
                let newMyPage = oldMyPage.copy(invitations: newInvitations)
                myPageSubject.send(newMyPage)
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
}

private extension MyPageVM{
    struct Loading: OptionSet{
        static let invitations = Self(rawValue: 1 << 0)
        static let house = Self(rawValue: 1 << 1)
        static let calendar = Self(rawValue: 1 << 2)
        static let event = Self(rawValue: 1 << 3)
        static let bookmarkedEvent = Self(rawValue: 1 << 4)
        static let all: Self = [house]
        
        let rawValue: UInt8
    }
}
