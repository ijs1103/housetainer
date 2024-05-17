//
//  UpdateSocialCalendarVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/20/24.
//

import Foundation
import Combine
import Photos

final class UpdateSocialCalendarVM {
    var createSocialCalendarPublisher: AnyPublisher<CreateSocialCalendar, Never>{
        createSocialCalendarSubject.eraseToAnyPublisher()
    }
    var toastPublisher: AnyPublisher<String, Never>{
        toastSubject.eraseToAnyPublisher()
    }
    
    let isEventUpdated = CurrentValueSubject<Bool?, Never>(nil)
    
    init(event: EventDetailResponse){
        self.event = event
        createSocialCalendarSubject.send(CreateSocialCalendar(
            title: event.title,
            date: event.date,
            scheduleType: ScheduleType(rawValue: event.scheduleType),
            imageRefs: [URL(string: event.imageUrls.first ?? "").map{ .url($0) }].compactMap{ $0 },
            link: event.relatedLink,
            description: event.detail
        ))
    }
    
    func updateEvent(_ event: EventToUpdate) async -> Bool {
        await NetworkService.shared.updateEvent(event)
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
    
    func save(){
        var oldSocialCalendar = createSocialCalendarSubject.value
        guard let imageRef = oldSocialCalendar.imageRefs.first, let date = oldSocialCalendar.date else{ return }
        oldSocialCalendar.isLoading = true
        createSocialCalendarSubject.send(oldSocialCalendar)
        uploadImageAndReturnFileName(eventId: event.id, imageReference: imageRef) { [weak self] imageUrl in
            guard let self, let imageUrl else{ return }
            let event = EventToUpdate(
                id: event.id,
                title: oldSocialCalendar.title,
                scheduleType: (oldSocialCalendar.scheduleType?.rawValue).ifNil(then: ""),
                date: date,
                detail: oldSocialCalendar.description,
                relatedLink: oldSocialCalendar.link.ifNil(then: ""),
                imageUrls: [imageUrl]
            )
            Task { [weak self] in
                guard let self else { return }
                let isUpdatingSuccess = await updateEvent(event)
                isEventUpdated.send(isUpdatingSuccess)
            }
        }
        oldSocialCalendar.isLoading = false
        createSocialCalendarSubject.send(oldSocialCalendar)
    }
    
    private let event: EventDetailResponse
    private let createSocialCalendarSubject = CurrentValueSubject<CreateSocialCalendar, Never>(.init())
    private let toastSubject = PassthroughSubject<String, Never>()
    
    private func uploadImageAndReturnFileName(eventId: String, imageReference: ImageReference, completion: @escaping (String?) -> Void) {
        switch imageReference {
        case .url(let url):
            completion(url.absoluteString)
        case.photo(let asset):
            convertPHAssetToData(asset: asset) { data in
                guard let data = data else {
                    print("convertPHAssetToData failed")
                    completion(nil)
                    return
                }
                Task {
                    let imageName = "\(UUID().uuidString).jpg"
                    let pathName = "\(eventId)/\(imageName)"
                    let imageUrl = "\(RemoteConfigManager.shared.data.supabaseUrl.absoluteString)/storage/v1/object/public/events/\(pathName)"
                    let isUploadingSuccess = await NetworkService.shared.uploadImage(table: .events, pathName: pathName, data: data)
                    if isUploadingSuccess {
                        completion(imageUrl)
                    } else {
                        print("image uploading failed")
                        completion(nil)
                    }
                }
            }
        default:
            completion(nil)
        }
    }
    
    func convertPHAssetToData(asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let targetWidth = aspectRatio >= 1 ? CGFloat(min(1280, asset.pixelWidth)) : 1280 * aspectRatio
        let targetHeight = aspectRatio < 1 ? CGFloat(min(1280, asset.pixelHeight)) : 1280 / aspectRatio
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, info in
            guard let image = image else {
                completion(nil)
                return
            }
            let imageData = image.jpegData(compressionQuality: 0.8)
            completion(imageData)
        }
    }
}
