//
//  SignupVM.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/13.
//

import Combine

final class SignupVM {
    let isChecked = CurrentValueSubject<Bool, Never>(false)
    let isEmailValid = CurrentValueSubject<Bool?, Never>(nil)
    let isInsertWaitingSuccessful = CurrentValueSubject<Bool?, Never>(nil)
    // 체크박스 체크 되어있고, 이메일 유효성 검사 통과하면 true가 되는 변수
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isChecked, isEmailValid).map { isChecked, isEmailValid in
            guard let isEmailValid = isEmailValid else { return false }
            return isChecked && isEmailValid
        }.eraseToAnyPublisher()
    }
}

extension SignupVM {
    func emailValidCheck(_ email: String) {
        let emailValid = RegexHelper.matchesRegex(email, regex: Regex.email)
        isEmailValid.send(emailValid)
    }
    
    func insertWaiting(_ waiting: Waiting) async {
        do {
            try await NetworkService.shared.insertWaiting(waiting)
            isInsertWaitingSuccessful.send(true)
        } catch {
            print("insertWaiting error: duplicate email or supabase error")
            isInsertWaitingSuccessful.send(false)
        }
    }
}
