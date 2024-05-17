//
//  SigninVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import UIKit
import SnapKit
import Combine
import Supabase
import AuthenticationServices
import CryptoKit
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import GoogleSignIn

final class SigninVC: BaseViewController {
    private let viewModel = SigninVM()
    private let supabase = SupabaseClient(supabaseURL: RemoteConfigManager.shared.data.supabaseUrl, supabaseKey: RemoteConfigManager.shared.data.supabaseAnonKey)
    private var subscriptions = Set<AnyCancellable>()
    fileprivate var currentNonce: String?
    
    private lazy var backgroundImage: UIImageView = {
        let view = UIImageView(image: Image.loginBg?.grayscaled)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let blackFilterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    private let logoImage = UIImageView(image: Icon.loginLogo)
    
    private lazy var kakaoButton: UIImageView = {
        let view = UIImageView(image: Image.kakaoButton)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapKakao))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var appleButton: UIImageView = {
        let view = UIImageView(image: Image.appleButton)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapApple))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var googleButton: UIImageView = {
        let view = UIImageView(image: Image.googleButton)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapGoogle))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [kakaoButton, appleButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension SigninVC {
    
    private func setUI() {
        [backgroundImage, logoImage, vStack].forEach {
            view.addSubview($0)
        }
        
        backgroundImage.addSubview(blackFilterView)
        
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blackFilterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        logoImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(228)
            make.centerX.equalToSuperview()
        }
        
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-80)
        }
    }
    
    @objc private func didTapNaver() {
        naverSignIn()
    }
    
    @objc private func didTapKakao() {
        kakaoSignIn()
    }
    
    @objc private func didTapGoogle() {
        googleSignIn()
    }
    
    @objc private func didTapApple() {
        appleSignIn()
    }
    
    private func navigateBasedOnRegistrationStatus() async {
        let isRegistered = await viewModel.isCurrentUserRegistered()
        if isRegistered {
            dismiss(animated: true)
        } else {
            let needsSignupInvitation = RemoteConfigManager.shared.data.needSignupInvitation
            if needsSignupInvitation {
                navigationController?.pushViewController(AgreeToTermsVC(), animated: true)
            } else {
                let isSignupSuccess = await viewModel.signupTestUser()
                if isSignupSuccess {
                    dismiss(animated: true)
                }
            }
        }
    }
}
//MARK: 구글로그인
extension SigninVC {
    private func googleSignIn() {
//        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
//            guard let self else { return }
//            guard error == nil else {
//                print(error?.localizedDescription ?? "GIDSignIn error")
//                return
//            }
//            
//            guard let idToken = signInResult?.user.idToken?.tokenString else {
//                print("empty google idToken")
//                return
//            }
//
//            let nonce = randomNonceString()
//            
//            Task {
//                await self.viewModel.signInWithIdToken(provider: .google, idToken: idToken, nonce: nonce)
//                await self.navigateBasedOnRegistrationStatus(handleUnregisteredUser: {
//                    self.navigationController?.pushViewController(InviteVC(), animated: true)
//                })
//            }
//          }
//        do {
//            let url = try supabase.auth.getOAuthSignInURL(provider: .google)
//            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "housetainer") { [weak self] url, error in
//                guard let self, let url else { return }
//                Task {
//                    _ = try await self.supabase.auth.session(from: url)
//                    await self.navigateBasedOnRegistrationStatus(handleUnregisteredUser: {
//                        self.navigationController?.pushViewController(InviteVC(), animated: true)
//                    })
//                }
//            }
//            session.presentationContextProvider = self
//            session.start()
//        } catch {
//            print("googleSignIn error")
//        }
    }
}

extension SigninVC: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}

//MARK: 애플로그인
extension SigninVC {
    private func appleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension SigninVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let idToken = credential.identityToken
                .flatMap({ String(data: $0, encoding: .utf8) })
            else {
                return
            }
            Task {
                await viewModel.signInWithIdToken(idToken: idToken, nonce: nonce)
                await navigateBasedOnRegistrationStatus()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}

extension SigninVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - 카카오 로그인
extension SigninVC {
    private func kakaoSignIn() {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { [unowned self] _, error in
                if let error = error {
                    print("kakao accessToken expired: ", error.localizedDescription)
                    return
                }
                kakaoSigninNormally()
            }
        } else {
            kakaoSigninNormally()
        }
    }
    
    private func kakaoSigninNormally() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] _, error in
                guard let self else { return }
                if let error = error {
                    print("loginWithKakaoTalk error: ", error.localizedDescription)
                } else {
                    Task {
                        await self.getKakaoTokensAndSetSession()
                        await self.navigateBasedOnRegistrationStatus()
                    }
                }
            }
        } else { // 카카오톡 설치 안되어 있을때 카카오 계정으로 로그인
            UserApi.shared.loginWithKakaoAccount { [weak self] _, error in
                guard let self else { return }
                if let error = error {
                    print("loginWithKakaoAccount error:", error.localizedDescription)
                } else {
                    Task {
                        await self.getKakaoTokensAndSetSession()
                        await self.navigateBasedOnRegistrationStatus()
                    }
                }
            }
        }
    }
    
    private func getKakaoTokensAndSetSession() async {
        guard let oAuthToken = TokenManager.manager.getToken() else {
            print("cannot get kakao tokens")
            return
        }
                
        guard let response = await viewModel.invokeEdgeFunction(accessToken: oAuthToken.accessToken, refreshToken: oAuthToken.refreshToken, name: .kakao) else {
            print("cannot get edgeFunction response")
            return
        }
        
        if let error = response.error {
            view.makeToast(error.name == "AuthApiError" ? "다른 소셜 로그인으로 시도해 보세요." : error.message, duration: 3.0, position: .center)
            return
        }
        
        let newAccessToken = response.data.session.accessToken
        let newRefreshToken = response.data.session.refreshToken
        _ = await viewModel.createSessionFromTokens(accessToken: newAccessToken, refreshToken: newRefreshToken)
    }
}

// MARK: - 네이버로그인
extension SigninVC {
    private func naverSignIn() {
        let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
    }

    private func getNaverTokensAndSetSession() async {
        guard let (accessToken, refreshToken) = viewModel.naverTokens() else {
            print("cannot get naver tokens")
            return
        }
        
        guard let response = await viewModel.invokeEdgeFunction(accessToken: accessToken, refreshToken: refreshToken, name: .naver) else {
            print("cannot get edgeFunction response")
            return
        }
        
        let newAccessToken = response.data.session.accessToken
        let newRefreshToken = response.data.session.refreshToken
        _ = await viewModel.createSessionFromTokens(accessToken: newAccessToken, refreshToken: newRefreshToken)
    }
}

extension SigninVC: NaverThirdPartyLoginConnectionDelegate {
    // 로그인 버튼을 눌렀을 경우 열게 될 브라우저
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        
    }
    
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        Task {
            await getNaverTokensAndSetSession()
            await navigateBasedOnRegistrationStatus()
        }
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    // 로그아웃 할 경우 호출(토큰 삭제)
    func oauth20ConnectionDidFinishDeleteToken() {
        NaverThirdPartyLoginConnection.getSharedInstance()?.requestDeleteToken()
    }
    
    // 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
}
