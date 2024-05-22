//
//  AdControl.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/08/03.
//

import GoogleMobileAds

extension UIViewController: GADBannerViewDelegate {
    
    func setupBannerViewToBottom(height: CGFloat = 60, adUnitID: String, _ bannerView: GADBannerView) {
        //let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: height))
        //let bannerView = GADBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func removeBanner(_ bannerView: GADBannerView) {
        print("removeBanner 진입")
        bannerView.removeFromSuperview()
        
    }
    
    func setupGADInterstitialAd(adUnitID: String, completion: @escaping (GADInterstitialAd?) -> Void) {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { ad, error in
            
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                self.alert1(title: "광고 불러오기 에러", message: error.localizedDescription, actionTitle1: "확인")
                completion(nil)
                return
            }
            
            completion(ad)
        }
        
    }
    
    func setupGADrewardedAd(adUnitID: String, completion: @escaping (GADRewardedAd?) -> Void) {
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { ad, error in
            
            if let error = error {
                print("Failed to load reward ad with error: \(error.localizedDescription)")
                self.alert1(title: "광고 불러오기 에러", message: error.localizedDescription, actionTitle1: "확인")
                completion(nil)
                return
            }
            
            completion(ad)
        }
        
    }
    
    func setupGADrewardedInterstitialAd(adUnitID: String, completion: @escaping (GADRewardedInterstitialAd?) -> Void) {
        let request = GADRequest()
        
        GADRewardedInterstitialAd.load(withAdUnitID: adUnitID, request: request) { ad, error in
            
            if let error = error {
                print("Failed to load rewardedInterstitial ad with error: \(error.localizedDescription)")
                self.alert1(title: "광고 불러오기 에러", message: error.localizedDescription, actionTitle1: "확인")
                completion(nil)
                return
            }
            
            completion(ad)
        }
        
    }
}

