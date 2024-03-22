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
        do{
            let session = try await SupabaseClient.shared.auth.session
            
            guard let imageRef = imageRefs.first, let imageData = await imageRef.data else{ throw CreateSocialCalendarError.fileUploadFailure }
            let path = "\(session.user.id.uuidString)/\(Date().timeIntervalSince1970).jpg"
            let fileOptions = FileOptions(contentType: "image/jpeg")
            try await SupabaseClient.shared.storage.from("events")
                .upload(path: path, file: imageData, options: fileOptions)
            let data = try await ApolloClient.shared.perform(mutation: CreateSocialCalendarMutation(
                createdAt: Date().datetime(),
                title: title,
                scheduleType: scheduleType.rawValue,
                ownerId: session.user.id.uuidString,
                date: .init(wrap: date.datetime()),
                description: description,
                link: .init(wrap: description),
                fileName: path
            )
            )
            guard let data = data else{ throw CreateSocialCalendarError.notFound }
            return data.socialCalendar?.affectedCount != 0
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
