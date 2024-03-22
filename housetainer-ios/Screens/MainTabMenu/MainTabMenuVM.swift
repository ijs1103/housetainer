//
//  MainTabMenuVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/1/24.
//

import Combine

final class MainTabMenuVM {
    let isSocialCalendarTabSelected = CurrentValueSubject<Bool, Never>(true)
    let allEvents = CurrentValueSubject<[EventDetail]?, Never>(nil)
    let filteredEvents = CurrentValueSubject<[EventDetail]?, Never>(nil)
    let allHouses = CurrentValueSubject<[House]?, Never>(nil)
    let filteredHouses = CurrentValueSubject<[House]?, Never>(nil)
    let selectedCategory = CurrentValueSubject<Category, Never>(.currentEvents)
}

extension MainTabMenuVM {
    func fetchAllEvents() async {
        let eventResArray = await NetworkService.shared.fetchEvents()
        let allEvents = eventResArray?.map({ EventDetail(response: $0) })
        self.allEvents.send(allEvents)
    }
    
    func filterEvents(isPast: Bool) {
        guard let allEvents = self.allEvents.value else { return }
        let filteredEvents = allEvents.filter({ event in
            isPast ? event.isPast : !event.isPast
        })
        self.filteredEvents.send(filteredEvents)
    }
    
    func fetchAllHouses() async {
        let houseResArray: [HouseResponse]? = await NetworkService.shared.fetchHouses()
        let allHouses = houseResArray?.map({ House(response: $0) })
        self.allHouses.send(allHouses)
    }
    
    func filterHouses(category: HouseCategory) {
        guard let allHouses = self.allHouses.value else { return }
        let filteredHouses = allHouses.filter { house in
            house.category == category
        }
        self.filteredHouses.send(filteredHouses)
    }
    
    func selectCategory(_ category: Category) {
        self.selectedCategory.send(category)
    }
}
