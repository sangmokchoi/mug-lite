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
import GoogleSignIn
import FBAudienceNetwork
import AppTrackingTransparency
import AdSupport

let db = Firestore.firestore()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)

        // Pass user's consent after acquiring it. For sample app purposes, this is set to YES.
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        //FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        //FBAdSettings. setIsTestMode(false)
        sleep(1)
        //requestPermission()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        //requestPermission()
        
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
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("status: \(status)")
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized print("Authorized")
                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                    Analytics.setAnalyticsCollectionEnabled(true)

                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                    Analytics.setAnalyticsCollectionEnabled(false)

                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not determined")

                case .restricted:
                    print("Restricted")

                @unknown default: print("Unknown")
                }
            }
        } else {
            // Fallback on earlier versions
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // 구글 소셜 로그인 URL 스킴 처리
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]

        let handled = GIDSignIn.sharedInstance.handle(url)

        if handled {
            // 취소 처리
            if !GIDSignIn.sharedInstance.hasPreviousSignIn() {
                print("사용자가 구글 소셜 로그인을 취소했습니다.")
            }
        }

        return handled
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate 진입")
        let userUid = UserDefaults.standard.string(forKey: "uid")
        print("userUid: \(userUid)")
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            let bookmarkList = UserDefaults.standard.array(forKey: "bookmarkArray")
            print("if let userUid = UserDefaults.standard.string(forKey: uid) 진입")
            db.collection("BookmarkList").document(userUid).setData([
                "BookmarkList" : bookmarkList,
                "documentID" : userUid,
                "updateTime" : Date()
            ])
            { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("BookmarkList upload Done")
                }
            }
        } else {
            print("applicationWillTerminate else 진입")
        }
    }

}

