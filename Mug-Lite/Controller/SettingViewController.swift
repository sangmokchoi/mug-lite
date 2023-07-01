//
//  SettingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit
import StoreKit
import GoogleSignIn
import FirebaseAuth
import FBAudienceNetwork
//import FirebaseAuthUI

//배너 광고 (Banner Ads): FBAdView 클래스를 사용하여 배너 광고를 표시할 수 있습니다.
//전면 광고 (Interstitial Ads): FBInterstitialAd 클래스를 사용하여 전면 광고를 표시할 수 있습니다.
//네이티브 광고 (Native Ads): FBNativeAd 클래스를 사용하여 네이티브 광고를 표시하고 사용자 지정할 수 있습니다.
//비디오 광고 (Video Ads): FBVideoAdsManager 클래스를 사용하여 비디오 광고를 표시하고 관리할 수 있습니다.
//인앱 광고 (In-Stream Ads): FBInStreamAd 클래스를 사용하여 인앱 광고를 표시할 수 있습니다.
//상품 카탈로그 광고 (Dynamic Product Ads): FBDynamicProductAd 클래스를 사용하여 동적 상품 카탈로그 광고를 표시할 수 있습니다.

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBAdViewDelegate, FBInterstitialAdDelegate, FBNativeAdDelegate {

    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!
    
    var adView: FBAdView!
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    let tableViewMenuArray = ["피드백 보내기", "문의하기", "스토어 별점 남기기", "이용약관 및 개인정보 처리방침", "이용방법", "회원 탈퇴", "광고 문의"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.topItem?.title = "설정"// #\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        settingTableView.showsVerticalScrollIndicator = false
        profileButtonConfigure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileButtonConfigure), name: Notification.Name("profileButtonConfigure"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)
        
        adView = FBAdView(placementID: Constants.K.SettingVC_FBBannerAdPlacementID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
     
        adView.loadAd()
        print("adView.isAdValid: \(adView.isAdValid)")
        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //profileButtonConfigure()
        tableViewConfigure()
                
    }
    
    @objc func profileButtonConfigure(){
        print("profileButtonConfigure 진입")
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            profileButton.setTitle("로그아웃", for: .normal)
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail"){
                print("userEmail 설정 진입")
                DispatchQueue.main.async {
                    self.helloLabel.text = "반갑습니다"
                    self.userInfoLabel.text = "\(userEmail)"
                    self.userInfoLabel.textColor = .black
                    self.userInfoLabel.textAlignment = .left
                }
                
            }
        } else {
            profileButton.setTitle("로그인", for: .normal)
            print("로그인으로 세팅")
            DispatchQueue.main.async {
                self.helloLabel.text = "설정"
                self.userInfoLabel.text = ""
                self.userInfoLabel.textColor = .black
                self.userInfoLabel.textAlignment = .left
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        
    }
    
    @objc func stopLoadingView() {
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        print("profileButtonPressed")
        if let userUid = UserDefaults.standard.string(forKey: "uid") { // 로그인이 된 상태이므로 로그아웃을 해야함
            print("if let userUid")
            let alertController = UIAlertController(title: "로그아웃 하시겠습니까?", message: "로그아웃을 하려면 진행 버튼을 눌러주세요", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "진행", style: .default) { _ in
                // 로그아웃을 위한 함수 구현 필요
                if let currentUser = Auth.auth().currentUser {
                    if let providerID = currentUser.providerData.first?.providerID {
                        print("providerID: \(providerID)")
                        
                        if providerID == "apple.com" {
                            // 애플 계정으로 로그인한 경우
                            // 애플 로그아웃
                            
                        } else if providerID == "google.com" {
                            // 구글 계정으로 로그인한 경우
                            // 구글 로그아웃
                            GIDSignIn.sharedInstance.signOut()
                            GIDSignIn.sharedInstance.disconnect()
                        }
                    }
                }
                
                let firebaseAuth = Auth.auth()
                print("firebaseAuth: \(firebaseAuth)")
                do {
                    try firebaseAuth.signOut()
                    print("로그아웃 성공")
                    DispatchQueue.main.async {
                        self.deleteDeviceData() // 로그아웃 시, 디바이스에 저장된 키워드 리스트, 북마크 리스트가 보이지 않아야 함
                        
                        self.profileButton.setTitle("로그인", for: .normal)
                        print("로그인으로 세팅")
                        NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
                    }
                    self.alert1(title: "로그아웃이 완료되었습니다", message: "이전 화면으로 돌아갑니다", actionTitle1: "확인")
                    
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            
        }
            let action2 = UIAlertAction(title: "취소", style: .destructive)
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true)
            
        } else { // 로그인이 안된 상태이므로 로그인을 해야함
            performSegue(withIdentifier: "settingToProfile", sender: sender)
        }
        
    }
    
    private func tableViewConfigure() {
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewMenuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        
        cell.tableViewCellLabel.text = tableViewMenuArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        switch indexPath.row
        {
        case 0:
            print("피드백 보내기")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 1:
            print("문의하기")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2:
            print("스토어 별점 남기기") // 잘 됨
            //let url0 = "itms-apps://itunes.apple.com/app/id6448700074"
            if let url = URL(string: "itms-apps://apps.apple.com/app/id6448700074") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                } else {
                    print("앱스토어로 이동할 수 없습니다.")
                }
        case 3:
            print("이용약관 및 개인정보 처리방침")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 4:
            print("홈페이지")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 5:
            print("회원 탈퇴")
            
            // 회원 탈퇴 버튼
            let alertController = UIAlertController(title: "탈퇴하시겠어요?", message: "회원 정보가 삭제되면 복구할 수 없어요", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "확인", style: .default) { _ in
                print("확인 클릭")
                
                self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(self.loadingIndicator)

                NSLayoutConstraint.activate([
                    self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                ])
                self.loadingIndicator.startAnimating()
                
                if let currentUser = Auth.auth().currentUser {
                    if let providerID = currentUser.providerData.first?.providerID {
                        
                        let alertController = UIAlertController(title: "회원 탈퇴 작업을 진행합니다", message: "로그인 재인증 작업이 발생할 수 있습니다", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "확인", style: .default) { _ in
                            
                            if providerID == "apple.com" {
                                // 애플 계정으로 로그인한 경우
                                print("유저가 애플 계정으로 로그인함")
                                
                                // credential 추출
                                self.reAuthenticateSignInWithAppleFlow()
                                
                                
                            } else if providerID == "google.com" {
                                // 구글 계정으로 로그인한 경우
                                print("유저가 구글 계정으로 로그인함")
                                
                                // credential 추출
                                self.googleAuthenticate()
                                
                                // 구글 로그아웃
                                GIDSignIn.sharedInstance.signOut()
                                GIDSignIn.sharedInstance.disconnect()
                                
                            }
                            
                            
                        }
                        alertController.addAction(action1)
                        let action2 = UIAlertAction(title: "취소", style: .destructive)
                        alertController.addAction(action2)
                        self.present(alertController, animated: true)
                    }
                }
            }
            alertController.addAction(action1)
            let action2 = UIAlertAction(title: "취소", style: .destructive)
            alertController.addAction(action2)
            self.present(alertController, animated: true)
            
        case 6:
            print("광고 문의")
            alert1(title: "준비중입니다", message: "빠른 시일 내로 준비하도록 하겠습니다", actionTitle1: "확인")
        default:
            print("Error!")
        }
        
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
        //print("adView: \(adView)")
        print("adViewDidLoad 성공")
        self.view.addSubview(adView)

    }

    // 배너 광고 불러오기 실패 시 호출되는 메서드
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("광고 불러오기 실패: \(error)")
        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
        
    }

}

