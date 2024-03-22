//
//  SigninVM.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import Combine
import Supabase
import GoTrue
import NaverThirdPartyLogin

final class SigninVM: NSObject {
    private let client = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    let isMemberExisting = CurrentValueSubject<Bool?, Never>(nil)
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
            print("SupabaseClient error - appleSignIn")
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

    // 유저의 회원가입 여부를 확인하기 위한 메서드
    func isCurrentUserRegistered() async -> Bool {
        do {
            guard let loginId = await NetworkService.shared.userInfo()?.email else { return false }
            let member = try await NetworkService.shared.fetchMemberWithLoginId(loginId)
            if member != nil {
                return true
            }
        } catch {
            print("isCurrentUserRegistered - supabase error")
        }
        return false
    }
}
