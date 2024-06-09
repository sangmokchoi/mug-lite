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
import MessageUI
import AdSupport
import AppTrackingTransparency
import SafariServices
import GoogleMobileAds
import AcknowList
//import FirebaseAuthUI

//배너 광고 (Banner Ads): FBAdView 클래스를 사용하여 배너 광고를 표시할 수 있습니다.
//전면 광고 (Interstitial Ads): FBInterstitialAd 클래스를 사용하여 전면 광고를 표시할 수 있습니다.
//네이티브 광고 (Native Ads): FBNativeAd 클래스를 사용하여 네이티브 광고를 표시하고 사용자 지정할 수 있습니다.
//비디오 광고 (Video Ads): FBVideoAdsManager 클래스를 사용하여 비디오 광고를 표시하고 관리할 수 있습니다.
//인앱 광고 (In-Stream Ads): FBInStreamAd 클래스를 사용하여 인앱 광고를 표시할 수 있습니다.
//상품 카탈로그 광고 (Dynamic Product Ads): FBDynamicProductAd 클래스를 사용하여 동적 상품 카탈로그 광고를 표시할 수 있습니다.

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!
    
    let archiveVC = AcrhiveViewController()
    
    var countdownTimer: Timer?
    var screenTimeSec = 31
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let loadingIndicator_medium = UIActivityIndicatorView(style: .medium)
    let countdownLabel = UILabel()
    
    let tableViewMenuArray = //["피드백 보내기", "이용약관", "개인정보 처리방침", "이용방법", "회원 탈퇴"]
    //["피드백 보내기", "이용약관", "개인정보 처리방침", "이용방법", "회원 탈퇴", "광고 문의", "광고 보고 포인트 받기", "결제", "스토어 별점 남기기"]
    //["피드백 보내기", "이용약관", "개인정보 처리방침", "이용방법", "회원 탈퇴", "결제"]
    ["피드백 보내기", "이용약관", "개인정보 처리방침", "이용방법", "회원 탈퇴", "결제", "광고 보고 포인트 받기", "스토어 별점 남기기", "오픈소스 라이센스"]
    
    var bannerView: GADBannerView! = GADBannerView(adSize: GADAdSizeBanner)
    private var GADrewardedAd: GADRewardedAd?
    private var GADrewardedInterstitialAd: GADRewardedInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.topItem?.title = "설정"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        settingTableView.showsVerticalScrollIndicator = false
        profileButtonConfigure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileButtonConfigure), name: Notification.Name("profileButtonConfigure"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)
        
        //setupBannerViewToBottom(adUnitID: Constants.GoogleAds.settingVCBannerAd)
        //bannerView = GADBannerView(adSize: GADAdSizeBanner) // 320 X 50
    
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("광고 추적이 허용된 상태입니다. Tracking authorization status: Authorized")
                    // 광고 추적이 허용된 상태입니다. 원하는 작업 수행
                    // IDFA 가 활성화된 광고를 송출해야함
                    self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.settingVCBannerAdwithIDFA, self.bannerView)
                case .denied:
                    print("광고 추적이 거부된 상태입니다. Tracking authorization status: Denied")
                    // 광고 추적이 거부된 상태입니다. 원하는 작업 수행
                    // IDFA 가 활성화되지 않은 광고를 송출해야함
                    self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.settingVCBannerAdNOIDFA, self.bannerView)

                case .restricted, .notDetermined:
                    print("권한이 제한되었거나 아직 결정되지 않았습니다. Tracking authorization status: Restricted or Not Determined")
                    // 앱 추적 권한이 제한되었거나 아직 결정되지 않은 상태입니다.
                    DispatchQueue.main.async {
                        self.requestPermission()
                    }
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewConfigure()
        
    }
    
    @objc func profileButtonConfigure(){
        print("profileButtonConfigure 진입")
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            profileButton.setTitle("로그아웃", for: .normal)
            if let userFriendCode = UserDefaults.standard.string(forKey: "friendCode"){
                print("userEmail 설정 진입")
                DispatchQueue.main.async {
                    
                    //NotificationCenter.default.post(name: Notification.Name("handleLoadTrendingNews"), object: nil)
                    self.helloLabel.text = "반갑습니다"
                    self.userInfoLabel.text = "친구코드: \(userFriendCode)"
                    self.userInfoLabel.textColor = UIColor(named: "AccentTintColor")
                    self.userInfoLabel.textAlignment = .left
                    
                    self.loadPoint {
                        DispatchQueue.main.async {
                            let userPoint = UserDefaults.standard.integer(forKey: "point")
                            
                            let attributedString = NSMutableAttributedString(string: "")
                            let imageAttachment = NSTextAttachment()
                            imageAttachment.image = UIImage(named: "gearshape.fill") //UIImage(named: "cup.and.saucer.fill")
                            imageAttachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
                            
                            attributedString.append(NSAttributedString(attachment: imageAttachment))
                            attributedString.append(NSAttributedString(string: " \(userPoint) P"))
                            
                            self.pointLabel.attributedText = attributedString
                            self.pointLabel.sizeToFit()
                            self.pointLabel.text = "☕ \(userPoint) P"
                            print("self.pointLabel.text 세팅 완료")
                        }
                    }
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
                
                self.pointLabel.text = "0 P"
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
                        self.profileButtonConfigure()
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
        // 로그인이 선행되어야 함
        let userUid = UserDefaults.standard.string(forKey: "uid")
        let userFriendCode = UserDefaults.standard.string(forKey: "friendCode")
        //["피드백 보내기", "스토어 별점 남기기", "이용약관 및 개인정보 처리방침", "이용방법", "회원 탈퇴", "광고 문의", "광고 보고 포인트 받기", "결제"]
        switch indexPath.row
        {
        case 0:
            print("피드백 보내기")
            
            if userUid == nil || userUid == "" { // 현재 로그아웃 시에는 클릭이 가능한 상황이라 수정 필요
                loginAlert()
            } else {
                // 이메일 사용가능한지 체크하는 if문
                if MFMailComposeViewController.canSendMail() {
                    
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                    let userUid = UserDefaults.standard.string(forKey: "uid")
                    
                    let compseVC = MFMailComposeViewController()
                    compseVC.mailComposeDelegate = self
                    
                    compseVC.setToRecipients(["simonwork177@gmail.com"])
                    compseVC.setSubject("mug-lite 문의사항 및 피드백")
                    compseVC.setMessageBody(
                        "===============\nmug-lite 이용 중 불편한 점이나 개선점이 있다면 피드백을 부탁드립니다.\n\nModel: \(UIDevice.current.name)\n친구코드: \(String(describing: userFriendCode))\n\(String(describing: userUid))\nOS Version: \(UIDevice.current.systemVersion)\nVersion : \(version)\n\n(아래에 원하시는 내용을 적어주세요. 스크린샷까지 첨부해주시면 더욱 큰 도움이 됩니다. 감사합니다)\n===============\n", isHTML: false)
                    
                    self.present(compseVC, animated: true, completion: nil)
                    
                } else { // 메일 사용이 불가한 경우
                    alert1(title: "메일 전송 실패", message: "iPhone의 mail 앱 설정을 확인해주세요", actionTitle1: "확인")
                }
            }
        case 1:
            print("이용약관")
            if let url = URL(string: "https://sites.google.com/view/mug-lite-policy/%ED%99%88") {
                let URL = url
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let safariVC = SFSafariViewController(url: URL, configuration: config)
                safariVC.transitioningDelegate = self
                safariVC.modalPresentationStyle = .pageSheet
                
                present(safariVC, animated: true, completion: nil)
                //UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2:
            print("개인정보 처리방침")
            if let url = URL(string: "https://sites.google.com/view/mug-lite-privacy-policy/%ED%99%88") {
                let URL = url
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let safariVC = SFSafariViewController(url: URL, configuration: config)
                safariVC.transitioningDelegate = self
                safariVC.modalPresentationStyle = .pageSheet
                
                present(safariVC, animated: true, completion: nil)
                //UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 3:
            print("이용방법")
            if let url = URL(string: "https://sites.google.com/view/howtouse-mug-lite/%ED%99%88") {
                let URL = url
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let safariVC = SFSafariViewController(url: URL, configuration: config)
                safariVC.transitioningDelegate = self
                safariVC.modalPresentationStyle = .pageSheet
                
                present(safariVC, animated: true, completion: nil)
                //UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 4:
            print("회원 탈퇴")
            if userUid == nil || userUid == "" { // 현재 로그아웃 시에는 클릭이 가능한 상황이라 수정 필요
                loginAlert()
            } else {
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
                    
                    if let currentUser = Auth.auth().currentUser {
                        if let providerID = currentUser.providerData.first?.providerID {
                            
                            let alertController = UIAlertController(title: "회원 탈퇴 작업을 진행합니다", message: "로그인 재인증 작업이 발생할 수 있습니다", preferredStyle: .alert)
                            let action1 = UIAlertAction(title: "확인", style: .default) { _ in
                                self.loadingIndicator.startAnimating()
                                self.view.isUserInteractionEnabled = false
                                
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
            }
        case 5:
            print("결제")
            
            if userUid == nil || userUid == "" {
                loginAlert()
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let PayViewController = storyboard.instantiateViewController(identifier: "PayViewController")
                PayViewController.modalPresentationStyle = .automatic
                self.show(PayViewController, sender: nil)
            }
        case 6:
            print("광고 보고 포인트 받기")
    
            
            let alertController = UIAlertController(title: "광고를 1번 시청하면\n450 포인트를 받을 수 있습니다", message: "포인트는 뉴스를 불러오는데 사용됩니다.\n(광고를 1번 불러오는데 150 포인트가 소모됩니다)\n광고를 시청하시겠습니까?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "취소", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
                
                if userUid == nil || userUid == "" { // 현재 로그아웃 시에는 클릭이 가능한 상황이라 수정 필요
                    self.loginAlert()
                    
                } else {

                    // 광고를 봤는지, 안봤는지를 먼저 확인한 다음에 CountDown을 해야함
                    if !self.countdown() { // 30초가 안 지났음
                        self.alert1(title: "광고를 시청한지 30초가 지나지 않았어요", message: "조금만 더 기다려주세요", actionTitle1: "확인")
                    } else { // 30초가 지남
                        
                        if let cell = tableView.cellForRow(at: indexPath) {
                            
                            // loadingIndicator_medium 설정
                            self.loadingIndicator_medium.translatesAutoresizingMaskIntoConstraints = false
                            cell.addSubview(self.loadingIndicator_medium)
                            
                            // loadingIndicator_medium를 셀의 오른쪽에 배치
                            NSLayoutConstraint.activate([
                                self.loadingIndicator_medium.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                                self.loadingIndicator_medium.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16)
                            ])
                            
                            self.loadingIndicator_medium.startAnimating()
                            self.view.isUserInteractionEnabled = false
                            
                        }
                        
                        ATTrackingManager.requestTrackingAuthorization { status in
                            DispatchQueue.main.async {
                                switch status {
                                case .authorized:
                                    print("광고 추적이 허용된 상태입니다. Tracking authorization status: Authorized")
                                    // 광고 추적이 허용된 상태입니다. 원하는 작업 수행
                                    //self.rewardedVideoAd.load()
                                    
                                    // IDFA 가 활성화된 광고를 송출해야함
                                    self.GADrewardedAdShowWithIDFA()
                                case .denied:
                                    print("광고 추적이 거부된 상태입니다. Tracking authorization status: Denied")
                                    // 광고 추적이 거부된 상태입니다. 원하는 작업 수행
                                    //self.rewardedInterstitialAd.load()
                                    
                                    // IDFA 가 활성화되지 않은 광고를 송출해야함
                                    self.GADrewardedAdShowNoIDFA()
                                    //self.GADrewardedInterstitialAdShow()
                                case .restricted, .notDetermined:
                                    print("권한이 제한되었거나 아직 결정되지 않았습니다. Tracking authorization status: Restricted or Not Determined")
                                    // 앱 추적 권한이 제한되었거나 아직 결정되지 않은 상태입니다.
                                    DispatchQueue.main.async {
                                        self.requestPermission()
                                    }
                                @unknown default:
                                    print("Unknown authorization status")
                                }
                            }
                        }
                    }
                }
                
            }
            alertController.addAction(action2)
            self.present(alertController, animated: true)
            
            
            
        case 7:
            print("스토어 별점 남기기") // 잘 됨
            //let url0 = "itms-apps://itunes.apple.com/app/id6448700074"
            if let url = URL(string: "itms-apps://apps.apple.com/app/id6450693152") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                print("앱스토어로 이동할 수 없습니다.")
            }
        case 8:
            print("오픈소스 라이센스") // 잘 됨

            let acknowList = AcknowListViewController(fileNamed: "Pods-Mug-Lite-acknowledgements")
            acknowList.modalPresentationStyle = .automatic
            acknowList.title = "오픈소스 라이센스"
        
        
            let doneButton = acknowList.navigationItem.leftBarButtonItem
            doneButton?.tintColor = UIColor.blue
            
                    // 새 네비게이션 컨트롤러로 감싸서 모달로 표시
                    let navController = UINavigationController(rootViewController: acknowList)
                    self.present(navController, animated: true, completion: nil)

        default:
            print("Error!")
        }
    }
    
}

extension SettingViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension NSObject {
    
    func pointUpdate(newUserPoint: Int, completion: @escaping() -> Void) {
        // 포인트 사용시에는 newUserPoint로 입력되어야 함
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            let userPoint = UserDefaults.standard.integer(forKey: "point")
            
            let uploadPoint = newUserPoint + userPoint
            print("pointUpdate uploadPoint: \(uploadPoint)")
            
            UserDefaults.standard.setValue(uploadPoint, forKey: "point")
            
            db.collection("UserInfo").document(userUid).updateData(["point": uploadPoint]
            ) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("userInfo upload Done")
                }
                
                completion()
            }
        }
    }
    
    func loadPoint(completion: @escaping () -> Void) {
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            print("loadPoint 진입")
            //let userPoint = UserDefaults.standard.integer(forKey: "point")
            //print("loadPoint old userPoint: \(userPoint)")
            db.collection("UserInfo").document(userUid).addSnapshotListener { documentSnapshot, error in
                
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                let newPoint = data["point"] as! Int
                UserDefaults.standard.set(newPoint, forKey: "point")
                print("loadPoint new userPoint: \(newPoint)")
                print("loadPoint 완료")
                completion()
            }
        }
    }
}

extension UIViewController {
    
    func loginAlert() {
        let alertController = UIAlertController(title: "알림", message: "로그인해서 mug-lite의 많은 기능을 이용해보세요", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "로그인", style: .default) { _ in
            print("회원가입 화면으로 이동")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SignupViewController = storyboard.instantiateViewController(identifier: "SignupViewController")
            SignupViewController.modalPresentationStyle = .automatic
            self.show(SignupViewController, sender: nil)
        }
        let action2 = UIAlertAction(title: "괜찮아요", style: .default, handler: nil)
        alertController.addAction(action1)
        alertController.addAction(action2)
        present(alertController, animated: true, completion: nil)
    }
    
    func settingVCAlert() {
        let alertController = UIAlertController(title: "포인트가 부족해요", message: "포인트를 충전해야 뉴스를 불러올 수 있어요", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default) { _ in
            print("SettingVC로 이동")
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 1
            }
        }
        alertController.addAction(action1)
        present(alertController, animated: true, completion: nil)
    }
    
    func incrementAdDisplayCount() {
        let userDefaults = UserDefaults.standard
        var adDisplayCount = userDefaults.integer(forKey: "AdDisplayCount")
        adDisplayCount += 1
        userDefaults.set(adDisplayCount, forKey: "AdDisplayCount")
    }
    
    func getAdDisplayCount() -> Int {
        let userDefaults = UserDefaults.standard
        let adDisplayCount = userDefaults.integer(forKey: "AdDisplayCount")
        return adDisplayCount
    }
    
    func resetAdDisplayCountIfNeeded() {
        if isNewDay() {
            resetAdDisplayCount()
        }
    }
    
    func resetAdDisplayCount() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(0, forKey: "AdDisplayCount")
        
        let currentDate = Date()
        userDefaults.set(currentDate, forKey: "LastDate")
    }
    
    func isNewDay() -> Bool {
        let userDefaults = UserDefaults.standard
        let lastDate = userDefaults.object(forKey: "LastDate") as? Date
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        if let lastDate = lastDate, calendar.isDate(lastDate, inSameDayAs: currentDate) {
            // 같은 날짜
            return false
        } else {
            // 다른 날짜
            return true
        }
    }
    
}

extension SettingViewController {
    
    func startCountDown() { // 1초씩 카운트 다운
        print("카운트다운 호출")
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if screenTimeSec > 0 {
            screenTimeSec -= 1
            
            if let cell = settingTableView.cellForRow(at: IndexPath(row: 6, section: 0)) {
                
                // loadingIndicator_medium 설정
                self.countdownLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.addSubview(self.countdownLabel)
                
                // loadingIndicator_medium를 셀의 오른쪽에 배치
                NSLayoutConstraint.activate([
                    self.countdownLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                    self.countdownLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16)
                ])
                DispatchQueue.main.async {
                    self.countdownLabel.text = "\(self.screenTimeSec)"
                }
            }
        } else { // 카운트다운이 0 아래로 떨어지는 경우이므로 레이블 제거 필요
            self.countdownLabel.text = ""
            // 타이머 중지
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            // screenTimeSec을 31으로 설정
            screenTimeSec = 31
        }
        
        // print(screenTimeSec)
    }
    
    func countdown() -> Bool {
        
        let lastTimeSeenRewardAds = UserDefaults.standard.string(forKey: "lastTimeSeenRewardAds")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        if let dateString = lastTimeSeenRewardAds {
            // 한 번이라도 시청을 한 상태이므로 30초 여부 파악 필요
            guard let referenceDate = formatter.date(from: dateString) else {
                print("Invalid reference date format")
                return false
            }
            // 0을 넘어서 -로 가기전에 uilabel 제거 필요
            let currentDate = Date()
            
            if currentDate.timeIntervalSince(referenceDate) > 31 {
                print("30초 가량 차이가 납니다.")
                return true
            } else {
                print("30초 이내입니다.")
                return false
            }
        } else {
            // 아직 한 번도 광고를 시청안해서 nil이 나오고 있음
            return true
        }
        
    }
}

extension SettingViewController : GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        alert1(title: "광고를 불러오지 못했습니다", message: "이용에 불편을 드려 죄송합니다", actionTitle1: "확인")
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator_medium.stopAnimating()
            self.loadingIndicator_medium.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
        
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        startCountDown()
        
        let date = DateFormatter()
        date.locale = Locale(identifier: Locale.current.identifier)
        date.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        date.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        print("date.string(from: Date()): \(date.string(from: Date()))")
        let dateString = date.string(from: Date())
        print("dateString: \(dateString)")
        UserDefaults.standard.set(dateString, forKey: "lastTimeSeenRewardAds")
        
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator_medium.stopAnimating()
            self.loadingIndicator_medium.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
        removeRewardedAd()
    }
    
    func show() {
        
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator_medium.stopAnimating()
            self.loadingIndicator_medium.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
        
        if let ad = GADrewardedAd {
            ad.present(fromRootViewController: self) {
                print("GADrewardedAd 진입")
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                
                // TODO: Reward the user.
                DispatchQueue.main.async {
                    self.pointUpdate(newUserPoint: 450) {
                        self.profileButtonConfigure()
                    }
                }
            }
        } else if let ad = GADrewardedInterstitialAd {
            ad.present(fromRootViewController: self) {
                print("GADrewardedInterstitialAd 진입")
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                
                // TODO: Reward the user.
                DispatchQueue.main.async {
                    self.pointUpdate(newUserPoint: 450) {
                        self.profileButtonConfigure()
                    }
                }
            }
            
        } else {
            print("Ad wasn't ready")
            alert1(title: "광고를 불러오지 못했습니다", message: "이용에 불편을 드려 죄송합니다", actionTitle1: "확인")
        }
    }
    
    func removeRewardedAd() {
        //interstitialAd?.delegate = nil // delegate 해제
        if let ad = GADrewardedAd {
            self.GADrewardedAd = nil
            print("removeRewardedAd nil 완료")
            
        } else if let ad = GADrewardedInterstitialAd{
            self.GADrewardedInterstitialAd = nil
            print("removeRewardedAd nil 완료")
            
        } else {
            print("광고 없음")
        }
        
        print("removeRewardedAd 진입")
    }
    
//    func GADrewardedInterstitialAdShow() {
//        self.setupGADrewardedInterstitialAd(adUnitID: Constants.GoogleAds.rewardedInterstitialAD) { GADRewardedAd in
//            print("setupGADrewardedInterstitialAd 시작됨")
//            self.GADrewardedInterstitialAd = GADRewardedAd
//            self.GADrewardedInterstitialAd?.fullScreenContentDelegate = self
//            
//            self.show()
//        }
//    }
    
    func GADrewardedAdShowWithIDFA() {
        self.setupGADrewardedAd(adUnitID: Constants.GoogleAds.rewardedVideoADwithIDFA) { GADRewardedAd in
            print("setupGADrewardedAd 시작됨")
            self.GADrewardedAd = GADRewardedAd
            self.GADrewardedAd?.fullScreenContentDelegate = self
            self.show()
        }
    }
    
    func GADrewardedAdShowNoIDFA() {
        self.setupGADrewardedAd(adUnitID: Constants.GoogleAds.rewardedVideoADNOIDFA) { GADRewardedAd in
            print("setupGADrewardedAd 시작됨")
            self.GADrewardedAd = GADRewardedAd
            self.GADrewardedAd?.fullScreenContentDelegate = self
            self.show()
        }
    }
}

