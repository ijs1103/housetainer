//
//  CreateSocialCalendar.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation

struct CreateSocialCalendar: Codable{
    var title: String = ""
    var date: Date?
    var scheduleType: ScheduleType?
    var imageRefs: [ImageReference] = []
    var link: String?
    var description: String = ""
    var canUpdate: Bool = false
    var isCompleted: Bool = false
    
    func validate() -> Bool{
        !title.isEmpty
        && date != nil
        && scheduleType != nil
        && !imageRefs.isEmpty
        && !description.isEmpty
    }
}
