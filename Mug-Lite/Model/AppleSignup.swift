//
//  AppleSignup.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import Foundation

import FirebaseAuth
import FirebaseAuthUI
import CryptoKit
import AuthenticationServices

fileprivate var currentNonce: String?

extension UIViewController : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // request 요청을 했을 때 none가 포함되어서 릴레이 공격을 방지
        // 추후 파베에서도 무결성 확인을 할 수 있게끔 함
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorizationController 출력")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        // nonce : 암호화된 임의의 난수, 단 한번만 사용 가능
        // 동일한 요청을 짧은 시간에 여러번 보내는 릴레이 공격 방지
        // 정보 탈취 없이 안전하게 인증 정보 전달을 위한 안전장치 // 안전하게 인증 정보를 전달하기 위해 nonce 사용
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return }
        
        //MARK: - 유저 개인 정보 (최초 회원가입 시에만 유저 정보를 얻을 수 있으며, 2회 로그인 시부터는 디코딩을 통해 이메일만 추출 가능. 이름은 불가)
        // token들로 credential을 구성해서 auth signin 구성 (google과 동일)
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        let userIdentifier = appleIDCredential.user
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
        
        let fullName = appleIDCredential.fullName
        
        let inputUserName = fullName?.givenName ?? "사용자"
        let inputUserEmail = appleIDCredential.email ?? "Apple로 로그인"
        
        Auth.auth().signIn(with: credential) { result, error  in
            if let error = error {
                print("error: \(error)")
            } else {
                let uid = Auth.auth().currentUser!.uid
                self.loadUserData(currentUserUid: uid, inputUserName: inputUserName, inputUserEmail: inputUserEmail, inputUserSignupTime: Date())
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
            print("사용자가 애플 소셜 로그인을 취소했습니다.")
            // Handle cancellation
            NotificationCenter.default.post(name: Notification.Name("loadingIsDone"), object: nil)
        } else {
            // Handle other errors
            // ...
        }
    }
}
//reAuthenticateSignInWithAppleFlow
extension SettingViewController {
    
    internal func reAuthenticateSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // request 요청을 했을 때 none가 포함되어서 릴레이 공격을 방지
        // 추후 파베에서도 무결성 확인을 할 수 있게끔 함
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
//    func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//            return String(format: "%02x", $0)
//        }.joined()
//        return hashString
//    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
    
    public override func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("authorizationController 출력")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        // nonce : 암호화된 임의의 난수, 단 한번만 사용 가능
        // 동일한 요청을 짧은 시간에 여러번 보내는 릴레이 공격 방지
        // 정보 탈취 없이 안전하게 인증 정보 전달을 위한 안전장치 // 안전하게 인증 정보를 전달하기 위해 nonce 사용
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
            return }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return }
        
        //MARK: - 유저 개인 정보 (최초 회원가입 시에만 유저 정보를 얻을 수 있으며, 2회 로그인 시부터는 디코딩을 통해 이메일만 추출 가능. 이름은 불가)
        // token들로 credential을 구성해서 auth signin 구성 (google과 동일)
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )

        Auth.auth().currentUser?.reauthenticate(with: credential) { result, error  in
            if let error = error {
                print("error: \(error)")
            } else {
                let uid = Auth.auth().currentUser!.uid
                self.deleteDeviceData()
                self.deleteServerData(uid: uid)
            }
        }
    }
    
    public override func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
            print("사용자가 애플 소셜 로그인을 취소했습니다.")
            // Handle cancellation
            NotificationCenter.default.post(name: Notification.Name("loadingIsDone"), object: nil)
        } else {
            // Handle other errors
            // ...
        }
    }
    
    func deleteDeviceData() {
        
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "signupTime")
        UserDefaults.standard.removeObject(forKey: "keywordList")
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        UserDefaults.standard.removeObject(forKey: "bookmarkArray")
        UserDefaults.standard.removeObject(forKey: "point") // 유저의 포인트 현황
        UserDefaults.standard.removeObject(forKey: "buttonPressed")
        UserDefaults.standard.removeObject(forKey: "previousDate")
        
        // 키워드 초기화
        DataStore.shared.userInputKeyword = []
        // ArchiveVC 상단 컬렉션 바 초기화
        NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
        
        // 북마크 초기화
        //DataStore.shared.bookmarkArray = []
        // BookmarkVC 초기화
        //NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)

    }
    
    func deleteServerData(uid: String) {
        db.collection("UserInfo").document(uid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("UserInfo Document successfully removed!")
                
                db.collection("KeywordList").document(uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("KeywordList Document successfully removed!")
                        
                        // 북마크 리스트도 지워야 함
                        db.collection("BookmarkList").document(uid).delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("BookmarkList Document successfully removed!")
                                // 로그인으로 버튼 이름 바뀌어야 함
                                NotificationCenter.default.post(name: Notification.Name("profileButtonConfigure"), object: nil)
                                // 로딩 화면 바도 생성되었다가 사라져야 함
                                NotificationCenter.default.post(name: Notification.Name("loadingIsDone"), object: nil)
                                self.alert1(title: "회원 탈퇴가 완료되었습니다", message: "mug-lite를 이용하려면 다시 로그인해주세요", actionTitle1: "확인")
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
