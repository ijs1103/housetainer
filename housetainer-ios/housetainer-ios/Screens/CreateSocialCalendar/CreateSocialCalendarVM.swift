//
//  CreateSocialCalendarVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import Combine

extension NSNotification.Name{
    static let socialCalendarCreated = Self(rawValue: "socialCalendarCreated")
}

extension CreateSocialCalendarVM{
    static let userInfoKey = "model"
}

@MainActor
final class CreateSocialCalendarVM {
    
    let isEventCreated = CurrentValueSubject<Bool?, Never>(nil)

    private let createSocialCalendarSubject = CurrentValueSubject<CreateSocialCalendar, Never>(.init())
    
    private let repository: CreateSocialCalendarRepository
    
    var createSocialCalendarPublisher: AnyPublisher<CreateSocialCalendar, Never>{
        createSocialCalendarSubject.eraseToAnyPublisher()
    }
    
    init(repository: CreateSocialCalendarRepository = CreateSocialCalendarRepositoryImpl()){
        self.repository = repository
    }
}

extension CreateSocialCalendarVM {
    
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
    
//    func save(){
//        Task.detached(priority: .userInitiated) { [weak self] in
//            guard let self else{ return }
//            
//            var createSocialCalendar = createSocialCalendarSubject.value
//            guard let date = createSocialCalendar.date, let scheduleType = createSocialCalendar.scheduleType else{ return }
//            
//            createSocialCalendar.isLoading = true
//            createSocialCalendarSubject.send(createSocialCalendar)
//            do{
//                try await repository.createSocialCalendar(
//                    title: createSocialCalendar.title,
//                    date: date,
//                    scheduleType: scheduleType,
//                    imageRefs: createSocialCalendar.imageRefs,
//                    link: createSocialCalendar.link,
//                    description: createSocialCalendar.description
//                )
//                UserDefaults.standard.setValue(nil, forKey: "CreateSocialCalendarVM.saveAsTemp")
//                
//                createSocialCalendar.isCompleted = true
//                createSocialCalendar.isLoading = false
//                createSocialCalendarSubject.send(createSocialCalendar)
//                
//                await NotificationCenter.default.post(name: .socialCalendarCreated, object: self, userInfo: [
//                    CreateSocialCalendarVM.userInfoKey: createSocialCalendar
//                ])
//            }catch{
//                createSocialCalendar.isLoading = false
//                createSocialCalendarSubject.send(createSocialCalendar)
//                print(error)
//            }
//        }
//    }
//    
    func createSocialCalendar() async {
        var createSocialCalendar = createSocialCalendarSubject.value
        createSocialCalendar.isLoading = true
        createSocialCalendarSubject.send(createSocialCalendar)
        guard let ownerId = await NetworkService.shared.userInfo()?.id.uuidString, let date = createSocialCalendar.date, let scheduleType = createSocialCalendar.scheduleType?.rawValue, let imageData = await createSocialCalendar.imageRefs.first?.data?.resizedImage() else { isEventCreated.send(false); return }
        let eventId = UUID().uuidString
        let imageName = "\(UUID().uuidString).jpg"
        let pathName = "\(eventId)/\(imageName)"
        let isImageUploadingSuccess = await NetworkService.shared.uploadImage(table: .events, pathName: pathName, data: imageData)
        if !isImageUploadingSuccess {
            isEventCreated.send(false)
            return
        }
        
        let imageUrls = "\(RemoteConfigManager.shared.data.supabaseUrl.absoluteString)/storage/v1/object/public/events/\(pathName)"
        let event = EventDTO(id: eventId, createdAt: Date(), title: createSocialCalendar.title, scheduleType: scheduleType, ownerId: ownerId, date: date, detail: createSocialCalendar.description, relatedLink: createSocialCalendar.link ?? "", displayType: "N", imageUrls: [imageUrls])
        do {
            try await NetworkService.shared.insertEvent(event)
            isEventCreated.send(true)
        } catch {
            print("insertEvent - supabase error")
            isEventCreated.send(false)
        }
        createSocialCalendar.isLoading = false
        createSocialCalendarSubject.send(createSocialCalendar)
    }
}


