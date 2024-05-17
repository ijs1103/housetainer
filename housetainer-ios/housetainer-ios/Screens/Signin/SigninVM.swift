//
//  SigninVM.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import Combine
import Supabase
import NaverThirdPartyLogin

final class SigninVM: NSObject {
    private let client = SupabaseClient(supabaseURL: RemoteConfigManager.shared.data.supabaseUrl, supabaseKey: RemoteConfigManager.shared.data.supabaseAnonKey)
}

extension SigninVM {
    func signInWithIdToken(idToken: String, nonce: String) async {
        do {
            try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
        } catch {
            print("\(error.localizedDescription) - signInWithIdToken error")
        }
    }
    
    func naverTokens() -> (String, String)? {
        let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow(), isValidAccessToken else {
            return nil
        }
        
        if let accessToken = loginInstance?.accessToken, let refreshToken = loginInstance?.refreshToken {
            return (accessToken, refreshToken)
        } else {
            return nil
        }
    }
    
    func invokeEdgeFunction(accessToken: String, refreshToken: String, name: EdgeFunctionName) async -> NaverSignUpEdgeFunctionResponse? {
        do {
            let response: NaverSignUpEdgeFunctionResponse = try await client.functions
                .invoke(
                    name.rawValue,
                    options: FunctionInvokeOptions(
                        body: ["accessToken": accessToken, "refreshToken": refreshToken]
                    )
                )
            return response
        } catch FunctionsError.httpError(let code, let data) {
            print("Function returned code \(code) with response \(String(data: data, encoding: .utf8) ?? "")")
        } catch FunctionsError.relayError {
            print("Relay error")
        } catch {
            print("Unknown error: \(error.localizedDescription)")
        }
        return nil
    }

    func createSessionFromTokens(accessToken: String, refreshToken: String) async -> Session? {
        do {
            let session = try await client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
            return session
        } catch {
            print("Setting session failed")
            return nil
        }
    }

    func isCurrentUserRegistered() async -> Bool {
        guard let loginId = await NetworkService.shared.userInfo()?.email else { return false }
        let existingMember = await NetworkService.shared.fetchMember(by: loginId)
        return existingMember != nil
    }
    
    func signupTestUser() async -> Bool {
        guard let id = await NetworkService.shared.userInfo()?.id.uuidString, let loginId = await NetworkService.shared.userInfo()?.email else { return false }
        let member = MemberResponse(id: id, memberStatus: "A", createdAt: Date(), memberType: "a", name: nil, loginId: loginId, username: "tu\(String(format: "%08d", Int.random(in: 0...99999999)))", gender: nil, birthday: nil, phoneNumber: nil, snsUrl: nil, profileUrl: nil, updatedAt: Date(), inviterId: nil)
        do {
            try await NetworkService.shared.insertMember(member)
            return true
        } catch {
            print("\(error.localizedDescription) - inserMember error")
            return false
        }
    }
}
