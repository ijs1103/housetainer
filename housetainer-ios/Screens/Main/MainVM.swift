//
//  MainVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/27/24.
//

import Combine
import Supabase
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

final class MainVM {
    private let client = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    let mainEvents = CurrentValueSubject<[Event]?, Never>(nil)
    let recentCalendars = CurrentValueSubject<[EventWithNickname]?, Never>(nil)
    let recentHouses = CurrentValueSubject<[HouseWithNickname]?, Never>(nil)
}

extension MainVM {
    func fetchMainEvents() async {
        let eventResArray = await NetworkService.shared.fetchMainEvents()
        let events = eventResArray?.map({ Event(response: $0) })
        mainEvents.send(events)
    }
    
    func fetchRecentCalendars() async {
        let eventResArray = await NetworkService.shared.fetchRecentEvents()
        let events = eventResArray?.map({ EventWithNickname(response: $0) })
        recentCalendars.send(events)
    }
    
    func fetchRecentHouses() async {
        let houseResArray = await NetworkService.shared.fetchRecentHouses()
        let houses = houseResArray?.map({ HouseWithNickname(response: $0) })
        recentHouses.send(houses)
    }
    
    func kakaoNaverSignOut() {
        if let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance() {
            loginInstance.resetToken()
        }
        if AuthApi.hasToken() {
            UserApi.shared.logout { error in
                if error != nil {
                    print("kakao signout error")
                }
            }
        }
    }
    
    func withDrawal() async {
        guard let memberId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return }
        await NetworkService.shared.deleteMember(id: memberId)
    }
}
