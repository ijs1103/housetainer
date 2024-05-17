//
//  CreateSocialCalendarRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Apollo
import Interstyle
import Supabase

enum CreateSocialCalendarError: Error{
    case fileUploadFailure
    case notFound
    case underlying(Error)
}

protocol CreateSocialCalendarRepository{
    @discardableResult
    func createSocialCalendar(
        title: String,
        date: Foundation.Date,
        scheduleType: ScheduleType,
        imageRefs: [ImageReference],
        link: String?,
        description: String
    ) async throws -> Bool
}

struct CreateSocialCalendarRepositoryImpl: CreateSocialCalendarRepository{
    func createSocialCalendar(title: String, date: Foundation.Date, scheduleType: ScheduleType, imageRefs: [ImageReference], link: String?, description: String) async throws -> Bool {
        guard let ownerId = await NetworkService.shared.userInfo()?.id.uuidString else { return false }
        do{
//            guard let imageRef = imageRefs.first, let imageData = await imageRef.data else{ throw CreateSocialCalendarError.fileUploadFailure }
//            let path = "\(ownerId)/\(Date().timeIntervalSince1970).jpg"
//            let fileOptions = FileOptions(contentType: "image/jpeg")
//            try await SupabaseClient.shared.storage.from("events")
//                .upload(path: path, file: imageData, options: fileOptions)
//            let data = try await ApolloClient.shared.perform(mutation: CreateSocialCalendarMutation(
//                title: title,
//                scheduleType: scheduleType.rawValue,
//                ownerId: ownerId,
//                date: .init(wrap: date.datetime()),
//                description: description,
//                link: .init(wrap: link),
//                fileName: path
//            )
//            )
//            let event = EventDTO(id: UUID().uuidString, createdAt: Date(), title: title, scheduleType: scheduleType.rawValue, ownerId: ownerId, date: date, detail: description, relatedLink: link ?? "", displayType: "N", imageUrls: [path])
//            try await NetworkService.shared.insertEvent(event)
            return true
        }catch{
            throw CreateSocialCalendarError.underlying(error)
        }
    }
}

struct CreateSocialCalendarRepositoryMock: CreateSocialCalendarRepository{
    
    func createSocialCalendar(title: String, date: Foundation.Date, scheduleType: ScheduleType, imageRefs: [ImageReference], link: String?, description: String) async throws -> Bool {
        true
    }
}
