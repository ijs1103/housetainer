//
//  ComplaintVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/2/24.
//

import Foundation
import Combine

final class ReportVM {
    private let reporteeId: String
    let isReportingSuccess = CurrentValueSubject<Bool?, Never>(nil)
    init(reporteeId: String) {
        self.reporteeId = reporteeId
    }
}

extension ReportVM {
    func report(reportReason: String, content: String) async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else {
            isReportingSuccess.send(false)
            return
        }
        let report = Report(id: UUID().uuidString, createdAt: Date(), title: reportReason, category: "신고", content: content, answeredAt: nil, answer: nil, reporteeId: reporteeId, reporterId: reporterId)
        do {
            try await NetworkService.shared.insertReport(report)
            isReportingSuccess.send(true)
        } catch {
            isReportingSuccess.send(false)
        }
    }
}
