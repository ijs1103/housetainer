//
//  MyPageVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import Apollo
import Interstyle
import Combine
import Supabase
import Combine

@MainActor
final class MyPageVM{
    init(id: String?, repository: MyPageRepository = MyPageRepositoryImpl()) {
        self.id = id
        self.repository = repository
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
    
    func load() {
        cancellables.removeAll(keepingCapacity: true)
        
        loading = .all
        Task.detached(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else{ return }
            defer{ loading = [] }
            
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
            }catch{
                print(error)
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Private
    private let id: String?
    private let myPageSubject = CurrentValueSubject<MyPage?, Never>(nil)
    private let repository: MyPageRepository
    private var cancellables: [AnyCancellable] = []
    private var loading: Loading = []
}

private extension MyPageVM{
    struct Loading: OptionSet{
        static let house = Self(rawValue: 1 << 0)
        static let calendar = Self(rawValue: 1 << 1)
        static let event = Self(rawValue: 1 << 2)
        static let bookmarkedEvent = Self(rawValue: 1 << 3)
        static let all: Self = [house]
        
        let rawValue: UInt8
    }
}
