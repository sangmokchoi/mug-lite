//
//  MainViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//
import Foundation
import UIKit
import WebKit
import FBAudienceNetwork

class KeywordViewController: UIViewController, FBAdViewDelegate, FBInterstitialAdDelegate {
    
//    let cellSpacingHeight: CGFloat = 1
//    
//    let mkt = "ko-KR"
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
//    var count = 0
//    var totalEstimatedResults = 0
//    var offset = 0
    var imageURLs: [URL] = []
    
    var adView: FBAdView!
    
    //let apiManager = APIManager()
    //let archiveVC = AcrhiveViewController()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //extractThumbnail()
        adView = FBAdView(placementID: Constants.K.KeywordRegisterVC_FBBannerAdPlacementID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
        
        //interstitialFBAD.delegate = self;
        //adView.loadAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.string(forKey: "uid") != nil {
            serverKeywordListExtract()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //tabBarController?.tabBar.isHidden = false
    }
    
    func serverKeywordListExtract() {
        
        let userUid = UserDefaults.standard.string(forKey: "uid")
        
        db.collection("KeywordList").whereField("documentID", isEqualTo: userUid).getDocuments { (querySnapshot, error) in
            if let error = error { // 나의 유저정보 로드
                print("There was NO saving data to firestore, \(error)")
            } else {
                if let documents = querySnapshot?.documents { // 키워정보 존재
                    if documents != [] {
                        for document in documents {
                            let data = document.data()
                            
                            let keywordList = data["KeywordList"] as! [String]
                            print("serverKeywordListExtract keywordList: \(keywordList)")
                            UserDefaults.standard.set(keywordList, forKey: "KeywordList")
                            // keywordList: ["손흥민", "제니", "조이", "유재석", "김민재"]
                        }
                    }
                }
            }
        }
    }
    
    func extractThumbnail() {

        guard let url = URL(string: "http://mosen.mt.co.kr/article/G1112129592#_enliple") else {
                    return
                }

        DispatchQueue.main.async {
            if let htmlString = try? String(contentsOf: url) {
                //print("htmlString: \(htmlString)")
                let imageURLs = self.extractFirstImageURL1(from: htmlString)
                print("imageURLs: \(imageURLs)")

            }
        }
    }

    func extractFirstImageURL1(from htmlString: String) -> URL? {
        let pattern = "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>"

        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            if let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) {
                let nsRange = match.range(at: 1)
                if let range = Range(nsRange, in: htmlString) {
                    let imageUrlString = String(htmlString[range])
                    print("imageUrlString: https:\(imageUrlString)")
                    if let imageUrl = URL(string: imageUrlString) {
                        return imageUrl
                    }
                }
            }
        }

        return nil
    }


    func checkImageContentType(for url: URL, completion: @escaping (Bool) -> Void) {
        let request = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpURLResponse = response as? HTTPURLResponse {
                //print("httpURLResponse: \(httpURLResponse)")
                if let contentType = httpURLResponse.allHeaderFields["Content-Type"] as? String {
                    print("contentType: \(contentType)")
                    completion(contentType.hasPrefix("image/"))
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }

        task.resume()
    }
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if interstitialAd.isAdValid {
            interstitialAd.show(fromRootViewController: self)
        }
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print(error)
    }
    
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        print("Did tap on ad")
    }


    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        print("Did close ad")
    }
    
    // 배너 광고 불러오기 성공 시 호출되는 메서드
    func adViewDidLoad(_ adView: FBAdView) {
        // 광고 뷰를 앱의 뷰 계층에 추가
        let screenHeight = view.bounds.height
        let adViewHeight = adView.frame.size.height

        adView.frame = CGRect(x: 0, y: screenHeight - adViewHeight, width: adView.frame.size.width, height: adView.frame.size.height)
        print("adView: \(adView)")
        self.view.addSubview(adView)
        

    }

    // 배너 광고 불러오기 실패 시 호출되는 메서드
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("광고 불러오기 실패: \(error)")
//        print("FBAdSettings.bidderToken: \(FBAdSettings.bidderToken)")
//        print("FBAdSettings.isBackgroundVideoPlaybackAllowed: \(FBAdSettings.isBackgroundVideoPlaybackAllowed)")
//        print("FBAdSettings.isMixedAudience: \(FBAdSettings.isMixedAudience)")
//        print("FBAdSettings.routingToken: \(FBAdSettings.routingToken)")
//        print("FBAdSettings.testDeviceHash(): \(FBAdSettings.testDeviceHash())")
//        print("FBAdSettings.hash(): \(FBAdSettings.hash())")
        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
        
    }

}


