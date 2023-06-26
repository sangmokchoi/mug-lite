//
//  GoogleSignup.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import Firebase

extension UIViewController {
    
    func googleSignIn() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { (user, error) in
            // 구글로 로그인 승인 요청
            if let error = error {
                print("googleSignIn ERROR", error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let profile = user?.profile
            let inputUserName = profile?.givenName
            let inputUserEmail = profile?.email
            
            //GIDSignIn을 통해 받은 idToken, accessToken으로 Firebase에 로그인
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken) // Access token을 부여받음
            
            Auth.auth().signIn(with: credential) { result, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    let uid = Auth.auth().currentUser!.uid
                    if let userUid = UserDefaults.standard.string(forKey: "uid") { // uid가 저장되어 있다? -> 이전에 로그인 한 적이 있다
                        self.loadUserData(currentUserUid: uid, inputUserName: inputUserName ?? "사용자님", inputUserEmail: inputUserEmail ?? "no email") // 애플로 재로그인하면, 이메일 확인이 불가능하므로 DB 상의 정보 조회
                        
                    } else { // uid가 저장되지 않았다? -> 신규 가입이거나 회원 탈퇴자다
                        self.setUserData(uid, inputUserName: inputUserName ?? "사용자", inputUserEmail: inputUserEmail ?? "no email") // 디바이스 상의 상태 셋업
                    }
                }
                return
            }
        print("구글 로그인")
        }
    }
    
}

extension UIViewController {
    
    func loadUserData(currentUserUid: String, inputUserName: String, inputUserEmail: String) {
        
        db.collection("UserData").document(currentUserUid).getDocument { (documentSnapshot, error) in
            if let error = error { // 나의 유저정보 로드
                print("There was NO saving data to firestore, \(error)")
            } else {
                if let document = documentSnapshot, document.exists { // 유저정보 존재
                    print("UserInfo Exists")
                    if let data = document.data() {
                        let uid = data["documentID"] as! String
                        let userName = data["userName"] as! String
                        let userEmail = data["userEmail"] as! String
                        
                        self.setUserData(uid, inputUserName: userName, inputUserEmail: userEmail)
                    }
                } else { // 유저 정보 없음 (신규가입)
                    self.setUserData(currentUserUid, inputUserName: inputUserName, inputUserEmail: inputUserEmail) // UserDefaults
                    self.userInfoServerUpload(currentUserUid, inputUserName: inputUserName, inputUserEmail: inputUserEmail) // FireBase
                }
            }
        }
    }
    
    func setUserData(_ uid: String, inputUserName: String, inputUserEmail: String) {
        
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(inputUserName, forKey: "userName")
        UserDefaults.standard.set(inputUserEmail, forKey: "userEmail")
        
        let userUid = UserDefaults.standard.string(forKey: "uid")
        let userName = UserDefaults.standard.string(forKey: "userName")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        
        let settingVC = SettingViewController()
        
        // 로그인 후에는 '로그인하기'가 유저의 이름 또는 이메일로 나타나야 함.
        DispatchQueue.main.async {
            
            //self.tabBarController?.selectedIndex = 1
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    func userInfoServerUpload(_ uid: String, inputUserName: String, inputUserEmail: String) {
        
        db.collection("UserInfo").document(uid).setData([
            "documentID" : uid,
            "userName" : inputUserName,
            "userEmail" : inputUserEmail,
            "signupTime" : Date()
        ]) { (error) in
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                print("upload Done")
            }
        }
    }
    
    func userKeywordServerUpload(_ uid: String, inputKeywordList: [String]) {
        // keywordList
        db.collection("KeywordList").document(uid).setData([
            "documentID" : uid,
            "KeywordList" : inputKeywordList,
            "updateTime" : Date()
        ]) { (error) in
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                print("upload Done")
            }
        }
    }
    
}
