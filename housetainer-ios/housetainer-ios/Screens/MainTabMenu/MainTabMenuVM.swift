//
//  MainTabMenuVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/1/24.
//

import Combine

final class MainTabMenuVM {
    let filteredEvents = CurrentValueSubject<[EventDetail]?, Never>(nil)
    let allHouses = CurrentValueSubject<[House]?, Never>(nil)
    let filteredHouses = CurrentValueSubject<[House]?, Never>(nil)
    let selectedCategory = CurrentValueSubject<Category, Never>(.currentEvents)
}

extension MainTabMenuVM {
    func filterEvents(isPast: Bool) async {
        isPast ? await fetchPastEvents() : await fetchOngoingEvents()
    }
    
    private func fetchOngoingEvents() async {
        let responses = await NetworkService.shared.fetchOngoingEvents()
        let ongoingEvents = responses?.map({ EventDetail(response: $0) })
        self.filteredEvents.send(ongoingEvents)
    }
    
    private func fetchPastEvents() async {
        let responses = await NetworkService.shared.fetchPastEvents()
        let pastEvents = responses?.map({ EventDetail(response: $0) })
        self.filteredEvents.send(pastEvents)
    }
    
    func fetchAllHouses() async {
        let houseResArray: [HouseResponse]? = await NetworkService.shared.fetchHouses()
        let allHouses = houseResArray?.map({ House(response: $0) })
        self.allHouses.send(allHouses)
    }
    
    func filterHouses(category: HouseCategory) {
        guard let allHouses = self.allHouses.value else { return }
        
        let filteredHouses = allHouses
            .filter { $0.category == category }
            .sorted { $0.createdAt < $1.createdAt }
        
        self.filteredHouses.send(filteredHouses)
    }
    //TODO: 카테고리로 Fetch house
//    private func fetchHouses(by category: HouseCategory) {
//        let responses = await NetworkService.shared.fetchHouses(by: category)
//    }
    
    func selectCategory(_ category: Category) {
        self.selectedCategory.send(category)
    }
}
