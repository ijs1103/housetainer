//
//  AskingVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/5/24.
//

import Foundation
import Combine

final class AskingVM {
    let isAskingSuccess = CurrentValueSubject<Bool?, Never>(nil)
}

extension AskingVM {
    func ask(title: String, content: String) async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else {
            isAskingSuccess.send(false)
            return
        }
        let report = Report(id: UUID().uuidString, createdAt: Date(), title: title, category: "문의", content: content, answeredAt: nil, answer: nil, reporteeId: nil, reporterId: reporterId)
        do {
            try await NetworkService.shared.insertReport(report)
            isAskingSuccess.send(true)
        } catch {
            isAskingSuccess.send(false)
        }
    }
}
