//
//  MainVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/27/24.
//

import Combine
import Supabase

final class MainVM {
    let eventMoments = CurrentValueSubject<[Event]?, Never>(nil)
    let eventPicks = CurrentValueSubject<[EventWithNickname]?, Never>(nil)
    let housePicks = CurrentValueSubject<[HouseWithNickname]?, Never>(nil)
    let haveUnreadAlarms = CurrentValueSubject<Bool?, Never>(nil)
    let filteredEvents = CurrentValueSubject<[EventDetail]?, Never>(nil)
    let allHouses = CurrentValueSubject<[House]?, Never>(nil)
    let filteredHouses = CurrentValueSubject<[House]?, Never>(nil)
    let selectedCategory = CurrentValueSubject<Category, Never>(.currentEvents)
    var blockedMembers: [BlockedMemberDTO] = []
    var isFetching = false
    var hasMoreData = true
    private var offset = 3
    private let limit = 3
}

extension MainVM {
    func fetchEventMoments() async {
        let response = await NetworkService.shared.fetchEventMoments()
        let nonBlockedEvents = response?.filter { event in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == event.ownerId
            }
        }.map(Event.init)
        eventMoments.send(nonBlockedEvents)
    }
    
    func fetchEventPicks() async {
        let response = await NetworkService.shared.fetchEventPicks()
        let nonBlockedEvents = response?.filter { event in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == event.ownerId
            }
        }.map(EventWithNickname.init)
        eventPicks.send(nonBlockedEvents)
    }
    
    func fetchHousePicks() async {
        let response = await NetworkService.shared.fetchHousePicks()
        let nonBlockedHouses = response?.filter { house in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == house.ownerId
            }
        }.map(HouseWithNickname.init)
        housePicks.send(nonBlockedHouses)
    }
    
    func withDrawal() async {
        guard let memberId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return }
        await NetworkService.shared.deleteMember(id: memberId)
    }
    
    func checkUnreadNotifications() async {
        guard let ownerId = await NetworkService.shared.userInfo()?.id.uuidString else { haveUnreadAlarms.send(false); return }
        let haveUnreadNotifications = await NetworkService.shared.checkUnreadNotifications(ownerId: ownerId)
        haveUnreadAlarms.send(haveUnreadNotifications)
    }
    
    func readNotifications() async {
        guard let ownerId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        await NetworkService.shared.readNotifications(ownerId: ownerId)
    }
    
    func deleteExpiredInvitations() async {
        guard let inviterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        await NetworkService.shared.updateStatusToExpiredInvitations(inviterId: inviterId)
    }
    
    func fetchEvents(isPast: Bool) async {
        let events: [EventDetailResponse]?

        events = isPast ? await NetworkService.shared.fetchPastEvents() : await NetworkService.shared.fetchOngoingEvents()
        
        guard let fetchedEvents = events else {
            self.filteredEvents.send(nil)
            return
        }
        
        let nonBlockedEvents = fetchedEvents.filter { event in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == event.ownerId
            }
        }
        
        self.filteredEvents.send(nonBlockedEvents.map(EventDetail.init))
    }
    
    func fetchAllHouses() async {
        let response = await NetworkService.shared.fetchHouses()
        let nonBlockedHouses = response?.filter { house in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == house.ownerId
            }
        }.map(House.init)
        self.allHouses.send(nonBlockedHouses)
    }
    
    func fetchHouses(by category: HouseCategory) async {
        let response = await NetworkService.shared.fetchHouses(by: category)
        let nonBlockedHouses = response?.filter { house in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == house.ownerId
            }
        }.map(House.init)
        self.filteredHouses.send(nonBlockedHouses)
    }
    
    func selectCategory(_ category: Category) {
        self.selectedCategory.send(category)
    }
    
    func fetchMoreEvents(isPast: Bool) async {
        guard let currentCount = filteredEvents.value?.count else { return }
        
        let fetchFunction = isPast ? NetworkService.shared.fetchPastEvents : NetworkService.shared.fetchOngoingEvents
        
        guard let newEvents = await fetchFunction(offset, offset + limit)?.map(EventDetail.init) else {
            return
        }
        
        guard !newEvents.isEmpty else {
            hasMoreData = false
            return
        }
        
        offset = offset + limit
        
        let nonBlockedEventDetails = newEvents.filter { newEvent in
            !blockedMembers.contains(where: { $0.blockedMemberId == newEvent.memberId })
        }

        if var existingEvents = filteredEvents.value {
            existingEvents.append(contentsOf: nonBlockedEventDetails)
            filteredEvents.send(existingEvents)
        } else {
            filteredEvents.send(newEvents)
        }
    }
    
    func fetchMoreAllHouses() async {
        guard let currentCount = allHouses.value?.count else { return }

        guard let newHouses = await NetworkService.shared.fetchHouses(from: offset, to: offset + limit)?.map(House.init) else { return }
        
        guard !newHouses.isEmpty else {
            hasMoreData = false
            return
        }
        
        offset = offset + limit
        
        let nonBlockedHouses = newHouses.filter { house in
            !blockedMembers.contains(where: { $0.blockedMemberId == house.ownerId })
        }

        if var existingHouses = allHouses.value {
            existingHouses.append(contentsOf: nonBlockedHouses)
            allHouses.send(existingHouses)
        } else {
            allHouses.send(newHouses)
        }
    }
    
    func fetchMoreHouses(category: HouseCategory) async {
        guard let currentCount = filteredHouses.value?.count else { return }

        guard let newHouses = await NetworkService.shared.fetchHouses(by: category, from: offset, to: offset + limit)?.map(House.init) else { return }
        
        guard !newHouses.isEmpty else {
            hasMoreData = false
            return
        }
        
        offset = offset + limit
        
        let nonBlockedHouses = newHouses.filter { house in
            !blockedMembers.contains(where: { $0.blockedMemberId == house.ownerId })
        }

        if var existingHouses = filteredHouses.value {
            existingHouses.append(contentsOf: nonBlockedHouses)
            filteredHouses.send(existingHouses)
        } else {
            filteredHouses.send(newHouses)
        }
    }
    
    func fetchBlockedMembers() async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMembers: [BlockedMemberDTO] = await NetworkService.shared.fetchBlockedMembers(reporterId: reporterId)
        self.blockedMembers = blockedMembers
    }
}
