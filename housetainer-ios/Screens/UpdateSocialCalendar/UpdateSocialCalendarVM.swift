//
//  UpdateSocialCalendarVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/20/24.
//

import Foundation
import Combine

final class UpdateSocialCalendarVM {
    func updateEvent(_ event: EventToUpdate) async -> Bool {
        await NetworkService.shared.updateEvent(event)
    }
}
