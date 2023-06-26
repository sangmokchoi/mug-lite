//
//  AppDelegate.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import UIKit
import FirebaseCore
import Firebase
import AuthenticationServices

let db = Firestore.firestore()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        sleep(1)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        if #available(iOS 13.0, *) {
            if let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") {
                print("userIdentifier:\(userIdentifier)")
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                    switch credentialState
                    {
                    case .authorized:
                        print("인증성공 상태")
                    case .revoked:
                        print("인증만료 상태")
                    default:
                        print(".notFound 등 이외 상태")
                    }
                }
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

