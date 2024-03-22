//
//  CreateSocialCalendarVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import Combine

final class CreateSocialCalendarVM{
    var createSocialCalendarPublisher: AnyPublisher<CreateSocialCalendar, Never>{
        createSocialCalendarSubject.eraseToAnyPublisher()
    }
    
    init(repository: CreateSocialCalendarRepository = CreateSocialCalendarRepositoryImpl()){
        self.repository = repository
    }
    
    func load(){
        do{
            if let jsonData = UserDefaults.standard.value(forKey: "CreateSocialCalendarVM.saveAsTemp") as? Data{
                let createSocialCalendar = try JSONDecoder().decode(CreateSocialCalendar.self, from: jsonData)
                createSocialCalendarSubject.send(createSocialCalendar)
            }
            UserDefaults.standard.setValue(nil, forKey: "CreateSocialCalendarVM.saveAsTemp")
        }catch{
            print(error)
        }
    }
    
    func updateTitle(_ title: String){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.title = title
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func updateDate(_ date: Date?){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.date = date
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func updateScheduleType(_ scheduleType: ScheduleType){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.scheduleType = scheduleType
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func updateImageRefs(_ imageRefs: [ImageReference]){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.imageRefs = imageRefs
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func updateLink(_ link: String){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.link = link
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func updateDescription(_ description: String){
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.description = description
        createSocialCalendar.canUpdate = createSocialCalendar.validate()
        createSocialCalendarSubject.send(createSocialCalendar)
    }
    
    func saveAsTemp(){
        let createSocialCalendar = createSocialCalendarSubject.value
        do{
            let jsonData = try JSONEncoder().encode(createSocialCalendar)
            UserDefaults.standard.setValue(jsonData, forKey: "CreateSocialCalendarVM.saveAsTemp")
        }catch{
            print(error)
        }
    }
    
    func save(){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            
            var createSocialCalendar = createSocialCalendarSubject.value
            guard let date = createSocialCalendar.date, let scheduleType = createSocialCalendar.scheduleType else{ return }
            do{
                try await repository.createSocialCalendar(
                    title: createSocialCalendar.title,
                    date: date,
                    scheduleType: scheduleType,
                    imageRefs: createSocialCalendar.imageRefs,
                    link: createSocialCalendar.link,
                    description: createSocialCalendar.description
                )
                UserDefaults.standard.setValue(nil, forKey: "CreateSocialCalendarVM.saveAsTemp")
                
                createSocialCalendar.isCompleted = true
                createSocialCalendarSubject.send(createSocialCalendar)
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: - Private
    private let createSocialCalendarSubject = CurrentValueSubject<CreateSocialCalendar, Never>(.init())
    private let repository: CreateSocialCalendarRepository
}
