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
                NotificationCenter.default.post(name: Notification.Name("loadingIsDone"), object: nil)
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
                    print("uid: \(uid)")
                    
                    self.loadUserData(currentUserUid: uid, inputUserName: inputUserName ?? "사용자님", inputUserEmail: inputUserEmail ?? "no email", inputUserSignupTime: Date()) // 애플로 재로그인하면, 이메일 확인이 불가능하므로 DB 상의 정보 조회
                }
                return
            }
        print("구글 로그인")
        }
    }
    
}

extension UIViewController {
    
    func loadUserData(currentUserUid: String, inputUserName: String, inputUserEmail: String, inputUserSignupTime: Date) {
        
        let db = Firestore.firestore()
        var keywordList : [String] = []
        
        db.collection("UserInfo").whereField("documentID", isEqualTo: currentUserUid).getDocuments() { (querySnapshot, error) in
            if let error = error { // 나의 유저정보 로드
                print("There was NO saving data to firestore, \(error)")
            } else {
                if let documents = querySnapshot?.documents { // 유저정보 존재
                    print("documents: \(documents)")
                    if documents != [] {
                        for document in documents {
                            //print("document: \(document)")
                            let data = document.data()
                            print("data: \(data)")
                            
                            let uid = data["documentID"] as! String
                            let userName = data["userName"] as! String
                            let userEmail = data["userEmail"] as! String
                            let user_SignupTime = data["signupTime"] as! Timestamp
                            let userSignupTime = user_SignupTime.dateValue()
                            
                            db.collection("KeywordList").whereField("documentID", isEqualTo: currentUserUid).getDocuments { (querySnapshot, error) in
                                if let error = error { // 나의 유저정보 로드
                                    print("There was NO saving data to firestore, \(error)")
                                } else {
                                    if let documents = querySnapshot?.documents { // 키워정보 존재
                                        if documents != [] {
                                            for document in documents {
                                                let data = document.data()
                                                
                                                keywordList = data["KeywordList"] as! [String]
                                                print("loadUserData keywordList: \(keywordList)")
                                                //키워드 리스트 불러와서 저장
                                                self.setUserData(uid, inputUserName: userName, inputUserEmail: userEmail, inputSignupTime: userSignupTime, inputKeywordList: keywordList)
                                                print("유저정보와 키워드 리스트 모두 존재")
                                                // keywordList: ["손흥민", "제니", "조이", "유재석", "김민재"]
                                            }
                                        } else {
                                            self.setUserData(uid, inputUserName: userName, inputUserEmail: userEmail, inputSignupTime: userSignupTime, inputKeywordList: keywordList)
                                            print("유저정보만 존재 / 키워드 리스트 없음")
                                        }
                                    }
                                }
                            }
                        }
                    } else { // 유저 정보 없음 (신규가입)
                        self.setUserData(currentUserUid, inputUserName: inputUserName, inputUserEmail: inputUserEmail, inputSignupTime: inputUserSignupTime, inputKeywordList: keywordList) // UserDefaults
                        self.userInfoServerUpload(currentUserUid, inputUserName: inputUserName, inputUserEmail: inputUserEmail, inputUserSignupTime: inputUserSignupTime) // FireBase
                        print("유저 정보 없음 (신규가입)")
                    }
                }
            }
        }

    }
    
    func setUserData(_ uid: String, inputUserName: String, inputUserEmail: String, inputSignupTime: Date, inputKeywordList: [String]) {
        // 디바이스 상에 유저 정보 저장
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(inputUserName, forKey: "userName")
        UserDefaults.standard.set(inputUserEmail, forKey: "userEmail")
        UserDefaults.standard.set(inputSignupTime, forKey: "signupTime")
        UserDefaults.standard.set(inputKeywordList, forKey: "KeywordList")
        
        let userUid = UserDefaults.standard.string(forKey: "uid")
        let userName = UserDefaults.standard.string(forKey: "userName")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        let userSignupTime = UserDefaults.standard.string(forKey: "signupTime")
        let userKeywordList = UserDefaults.standard.array(forKey: "KeywordList") as! [String]
        print("userKeywordList: \(userKeywordList)")
        
        DispatchQueue.main.async {
            //self.tabBarController?.selectedIndex = 1
            DataStore.shared.userInputKeyword = userKeywordList
            
            NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("profileButtonConfigure"), object: nil)
            print("로그인 작업 완료")
            let userUid = UserDefaults.standard.string(forKey: "uid")
            print("userUid: \(userUid)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userInfoServerUpload(_ uid: String, inputUserName: String, inputUserEmail: String, inputUserSignupTime: Date) {
        
        db.collection("UserInfo").document(uid).setData([
            "documentID" : uid,
            "userName" : inputUserName,
            "userEmail" : inputUserEmail,
            "signupTime" : inputUserSignupTime
        ]) { (error) in
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                print("userInfo upload Done")
//                DispatchQueue.main.async {
//                    self.profileButton.setTitle("로그인", for: .normal)
//                }
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
                print("Keyword upload Done")
            }
        }
    }
    
//    func serverKeywordListExtract() {
//
//        let userUid = UserDefaults.standard.string(forKey: "uid")
//
//        db.collection("KeywordList").whereField("documentID", isEqualTo: userUid).getDocuments { (querySnapshot, error) in
//            if let error = error { // 나의 유저정보 로드
//                print("There was NO saving data to firestore, \(error)")
//            } else {
//                if let documents = querySnapshot?.documents { // 키워정보 존재
//                    if documents != [] {
//                        for document in documents {
//                            let data = document.data()
//
//                            let keywordList = data["KeywordList"] as! [String]
//                            print("keywordList: \(keywordList)")
//                            UserDefaults.standard.set(keywordList, forKey: "KeywordList")
//                            // keywordList: ["손흥민", "제니", "조이", "유재석", "김민재"]
//                        }
//                    }
//                }
//            }
//        }
//    }
    
}


extension SettingViewController {
    
    func googleAuthenticate() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { (user, error) in
            // 구글로 로그인 승인 요청
            if let error = error {
                print("googleSignIn ERROR", error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            
            //GIDSignIn을 통해 받은 idToken, accessToken으로 Firebase에 로그인
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken) // Access token을 부여받음
            
            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error  in
                if let error = error {
                    print("reauthenticate error: \(error)")
                } else {
                    print("User re-authenticated. result: \(String(describing: result))")
                    let uid = Auth.auth().currentUser!.uid
                    self.deleteDeviceData()
                    self.deleteServerData(uid: uid)
                }
            }
            print("구글 로그인")
        }
    }
}
