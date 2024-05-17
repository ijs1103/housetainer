//
//  AlarmVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/10/24.
//

import Foundation
import Combine

final class AlarmVM {
    let alarms = CurrentValueSubject<[NotificationData]?, Never>(nil)
    var isFetching = false
    var hasMoreData = true
}

extension AlarmVM {
    func fetchAlarms() async {
        guard let ownerId = await NetworkService.shared.userInfo()?.id.uuidString else { alarms.send(nil); return }
        guard let response = await NetworkService.shared.fetchNotifications(ownerId: ownerId) else {
            alarms.send(nil); return }
        let notifications = response.map(NotificationData.init)
        alarms.send(notifications)
    }
    
    func fetchMoreAlarms() async {        
        let currentCount = alarms.value?.count ?? 0
        let ownerId = await NetworkService.shared.userInfo()?.id.uuidString ?? ""
        
        guard let newNotifications = await NetworkService.shared.fetchNotifications(ownerId: ownerId, from: currentCount, to: currentCount + 9) else {
            return
        }
        
        if newNotifications.isEmpty {
            hasMoreData = false
            return
        }
        
        if var existingNotifications = alarms.value {
            existingNotifications.append(contentsOf: newNotifications.map(NotificationData.init))
            alarms.send(existingNotifications)
        } else {
            alarms.send(newNotifications.map(NotificationData.init))
        }
    }
}
