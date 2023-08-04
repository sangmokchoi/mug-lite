//
//  KeywordRegisterViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit
import OHCubeView
import SafariServices
import FBAudienceNetwork
import GoogleMobileAds
import AppTrackingTransparency

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class KeywordRegisterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, FBAdViewDelegate {
    
    @IBOutlet weak var keywordSearchBar: UISearchBar!
    @IBOutlet weak var followingKeywordCountLabel: UILabel!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var userInputKeyword : String = ""
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    var userData = UserData()
    let dataStore = DataStore.shared
    
    var adView: FBAdView!
    var bannerView: GADBannerView! = GADBannerView(adSize: GADAdSizeMediumRectangle)
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @objc override func dismissKeyboard() {
            view.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("keywordCollectionView.frame.height : \(keywordCollectionView.frame.height)")
        
        keywordCollectionView.dataSource = self
        keywordCollectionView.delegate = self
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.showsVerticalScrollIndicator = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        registerXib()
        configure()
        
        adView = FBAdView(placementID: Constants.K.KeywordRegisterVC_FBBannerAdPlacementID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
     
        //adView.loadAd()
        //bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("광고 추적이 허용된 상태입니다. Tracking authorization status: Authorized")
                    // IDFA 가 활성화된 광고를 송출해야함
                    self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.keywordRegisterVCBannerAdwithIDFA, self.bannerView)
                    
                case .denied:
                    print("광고 추적이 거부된 상태입니다. Tracking authorization status: Denied")
                    // 광고 추적이 거부된 상태입니다. 원하는 작업 수행

                    // IDFA 가 활성화되지 않은 광고를 송출해야함
                    self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.keywordRegisterVCBannerAdNOIDFA, self.bannerView)

                case .restricted, .notDetermined:
                    print("권한이 제한되었거나 아직 결정되지 않았습니다. Tracking authorization status: Restricted or Not Determined")
                    
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    func configure() {
        searchButton.layer.cornerRadius = 5
        searchButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        followButton.layer.cornerRadius = 5
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        keywordCollectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        if let flowLayout = keywordCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
          }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFollowingKeywordCountLabel()
            
        // dataStore.userInputKeyword의 변경을 감지하는 옵저버 설정
        NotificationCenter.default.addObserver(self, selector: #selector(userInputKeywordDidChange(_:)), name: NSNotification.Name(rawValue: "UserInputKeywordDidChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchTableViewScroll(_:)), name: NSNotification.Name(rawValue: "UserInputKeywordSearch"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let userInputKeywordArray = DataStore.shared.userInputKeyword
        
//        UserDefaults.standard.set(userInputKeywordArray, forKey: "keywordList")
//        let keywordList = UserDefaults.standard.array(forKey: "keywordList") as! [String]
//        
//        if let userUid = UserDefaults.standard.string(forKey: "uid") { // uid가 있다는 것은 유저가 가입한 적이 있다는 뜻임.
//            print("userUid: \(userUid)")
//            userKeywordServerUpload(userUid, inputKeywordList: keywordList)
//        }
        DispatchQueue.main.async {
            DataStore.shared.loadedKeywordSearchArray = []
            self.searchTableView = nil
        }
    }
    
    @objc func userInputKeywordDidChange(_ notification: Notification) {
        updateFollowingKeywordCountLabel()
        
    }

    func updateFollowingKeywordCountLabel() {
        let followingKeywordCount = dataStore.userInputKeyword.count
        followingKeywordCountLabel.text = "팔로우한 키워드: \(followingKeywordCount) / \(Constants.K.keywordLimit)"
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        
        let nibName2 = UINib(nibName: "KeywordCollectionView", bundle: nil)
        keywordCollectionView.register(nibName2, forCellWithReuseIdentifier: "KeywordCollectionView")
    }
    
    @IBAction func keywordSearchButton(_ sender: UIButton) {
        
        if let userInputKeyword = keywordSearchBar.text {
            
            if userInputKeyword == "" {
                alert1(title: "입력한 키워드가 없어요", message: "키워드를 입력해주세요", actionTitle1: "확인")
            } else {
                let pureCharacters = removeSpecialChars(text: userInputKeyword)

                if pureCharacters == true {
                    alert1(title: "특수기호는 입력할 수 없어요", message: "다시 한 번 입력해주세요", actionTitle1: "확인")
                    DispatchQueue.main.async {
                        self.keywordSearchBar.text = ""
                    }
                } else {
                    if !Constants.K.bannedKeywordList.contains(userInputKeyword) {
                        DataStore.shared.loadedKeywordSearchArray = []
                        DispatchQueue.main.async {
                            self.searchTableView.backgroundView = nil
                            // Show loading indicator
                            //UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                            self.loadingIndicator.center = self.view.center
                            self.view.addSubview(self.loadingIndicator)
                            self.loadingIndicator.startAnimating()
                            
                            // Disable user interaction during API request
                            self.view.isUserInteractionEnabled = false
                        }
                        apiNewsSearch(query: userInputKeyword, count: 20, mkt: Constants.K.mkt, offset: 0, keywordSearch: true, newsSearch: false) {
                            print("키워드 검색이 완료되었습니다")
                        }
                    } else {
                        alert1(title: "다른 키워드를 입력해주세요", message: "애플 정책에 의거하여 코로나 바이러스 관련 기사를 불러오지 않습니다", actionTitle1: "확인")
                    }

                }
            }
        }
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
    
    func removeSpecialChars(text: String) -> Bool {
        //let okayChars: Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
        //let filteredText = String(text.filter { okayChars.contains($0) }) // 특수기호를 필터링
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_-+=~`[]{}|:;,.<>?/")
        let filteredText = text.trimmingCharacters(in: specialChars)
        
        return text != filteredText // true이면 특수 기호가 제거되었음을 나타내고, false이면 특수 기호가 제거되지 않았음
    }
    
    @objc func searchTableViewScroll(_ notification: Notification) {
        DispatchQueue.main.async {
            
            self.searchTableView.reloadData()
            //let topIndexPath = IndexPath(row: self.searchTableView.numberOfRows(inSection: 0), section: 0)
            //self.searchTableView.scrollToRow(at: topIndexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        //hideKeyboardWhenTappedAround()
        
        if dataStore.userInputKeyword.count >= Constants.K.keywordLimit {
            alert1(title: "더 이상 키워드를 등록할 수 없어요", message: "기존 키워드를 삭제해야 등록할 수 있어요", actionTitle1: "확인")
        } else {
            if let userInputKeyword = keywordSearchBar.text {
                if userInputKeyword == "" {
                    alert1(title: "입력한 키워드가 없어요", message: "키워드를 입력해주세요", actionTitle1: "확인")
                } else {
                    if !dataStore.userInputKeyword.contains(userInputKeyword) && !Constants.K.bannedKeywordList.contains(userInputKeyword) {
                        // 데이터 배열에 유저가 입력한 키워드가 없으므로 그대로 진행
                        dataStore.userInputKeyword.append(userInputKeyword)
                        self.userInputKeyword = userInputKeyword
                    } else if dataStore.userInputKeyword.contains(userInputKeyword) && !Constants.K.bannedKeywordList.contains(userInputKeyword) {
                        // 코로나 관련 키워드는 아니지만, 기존 키워드 리스트에 등록하려는 키워드가 있음
                        // 데이터 배열에 유저가 입력한 키워드가 있으므로 재입력 필요
                        alert1(title: "동일한 키워드가 있어요", message: "다른 키워드를 입력해주세요", actionTitle1: "확인")
                    } else if !dataStore.userInputKeyword.contains(userInputKeyword) && Constants.K.bannedKeywordList.contains(userInputKeyword) {
                        // 기존 키워드 리스트에는 등록하려는 키워드가 없으나, 코로나 관련 키워드를 등록하려고 시도함
                        alert1(title: "다른 키워드를 입력해주세요", message: "애플 정책에 의거하여 코로나 바이러스 관련 기사를 불러오지 않습니다", actionTitle1: "확인")
                    }
                    DispatchQueue.main.async {
                        self.keywordSearchBar.text = ""
                    }
                }
                //print("dataStore.userInputKeyword: \(dataStore.userInputKeyword)")
                
                DispatchQueue.main.async {
                    self.keywordCollectionView.reloadData()
                    self.scrollToBottom()
                    NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "UserInputKeywordDidChangeNotification"), object: nil)
                    
                    if let userUid = UserDefaults.standard.string(forKey: "uid"){
                        let inputKeywordList = self.dataStore.userInputKeyword
                        self.userKeywordServerUpload(userUid, inputKeywordList: inputKeywordList)
                    }
                }
            }
        }
        
    }
    
    func scrollToBottom() {
        let lastSection = self.keywordCollectionView.numberOfSections - 1
        let lastItem = self.keywordCollectionView.numberOfItems(inSection: lastSection) - 1
        if lastSection >= 0 && lastItem >= 0 {
            let lastIndexPath = IndexPath(item: lastItem, section: lastSection)
            self.keywordCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //return UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.userInputKeyword.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let addedKeyword = dataStore.userInputKeyword[indexPath.row]
        let keywordLabelWidth = addedKeyword.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]).width

        let cellWidth = keywordLabelWidth + 30 // 키워드 레이블의 너비와 여백을 더한 값으로 셀의 너비 설정
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCollectionView", for: indexPath) as! KeywordCollectionView
        
        let deleteButton = UIButton(type: .close)
        //deleteButton.setTitle("x", for: .normal)
        //deleteButton.setImage(UIImage(named: "xmark"), for: .normal)
        let scaleRatio: CGFloat = 0.4
        deleteButton.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        deleteButton.contentMode = .scaleAspectFit
        deleteButton.setTitleColor(.systemGray, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        cell.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.leadingAnchor.constraint(equalTo: cell.keywordLabel.trailingAnchor, constant: -5).isActive = true
        //deleteButton.trailingAnchor.constraint(equalTo: cell.keywordLabel.trailingAnchor, constant: -10).isActive = true
        //deleteButton.centerYAnchor.constraint(equalTo: cell.keywordLabel.centerYAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: cell.keywordLabel.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: cell.keywordLabel.bottomAnchor).isActive = true
        
        //let layoutLine =
        cell.layer.cornerRadius = 12
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.systemGray.cgColor
        
        let addedKeyword = dataStore.userInputKeyword[indexPath.row]
        cell.keywordLabel.text = addedKeyword
        
        return cell
    }
    
    @objc private func deleteButtonTapped(sender: UIButton) {
        // 버튼이 눌렸을 때 수행할 동작을 여기에 구현합니다.
        print("Delete button tapped")
        
        let alertController = UIAlertController(title: "키워드 삭제", message: "선택한 키워드를 삭제합니다", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "삭제", style: .destructive) { UIAlertAction in
            print("삭제 버튼 클릭")
            guard let cell = sender.superview as? KeywordCollectionView else {
                print("cell에 문제 있음")
                return
            }
            // 셀의 인덱스를 찾습니다.
            guard let indexPath = self.keywordCollectionView.indexPath(for: cell) else {
                print("indexPath에 문제 있음")
                return
            }
            // 해당 키워드 값을 dataStore.userInputKeyword에서 삭제합니다.
            self.dataStore.userInputKeyword.remove(at: indexPath.row)
            // collectionView에서 해당 셀을 삭제합니다.
            self.keywordCollectionView.deleteItems(at: [indexPath])
            NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionViewDeleteButtonPressed"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UserInputKeywordDidChangeNotification"), object: nil)
            
            if let userUid = UserDefaults.standard.string(forKey: "uid"){
                let inputKeywordList = self.dataStore.userInputKeyword
                self.userKeywordServerUpload(userUid, inputKeywordList: inputKeywordList)
            }
            
            print("index.path: \(indexPath.row)")
            print("self.dataStore.userInputKeyword: \(self.dataStore.userInputKeyword)")
        }
        let action2 = UIAlertAction(title: "취소", style: .default)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // 셀 간의 세로 간격
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //셀 간의 가로 간격
        return 5
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       // 현재 검색 바의 텍스트와 새로 입력된 문자를 조합하여 최종 문자열을 얻습니다.
       guard let currentText = searchBar.text else { return true }
       let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespacesAndNewlines)

       // 최종 문자열의 길이가 30자 이하인지 확인합니다.
       return updatedText.count <= 30
   }
    //MARK: - FB ADS SETTING
    // 배너 광고 불러오기 성공 시 호출되는 메서드
    func adViewDidLoad(_ adView: FBAdView) {
        // 광고 뷰를 앱의 뷰 계층에 추가
        let screenHeight = view.bounds.height
        let adViewHeight = self.adView.frame.size.height
        let safeAreaBottom = view.safeAreaInsets.bottom

        self.adView.frame = CGRect(
            x: 0,
            y: screenHeight - adViewHeight - safeAreaBottom,
            width: self.adView.frame.size.width,
            height: self.adView.frame.size.height)
        //print("adView: \(adView)")
        print("adViewDidLoad 성공")
        showAd()
        
    }

    // 배너 광고 불러오기 실패 시 호출되는 메서드
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("광고 불러오기 실패: \(error)")
        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
    }
    
    func showAd() {
        print("showAd 진입")
        self.view.addSubview(adView)
        
//        let adView = FBAdView(placementID: Constants.K.KeywordRegisterVC_FBBannerAdPlacementID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
//        adView.delegate = self
//        self.adView = adView
        //print("configureInterstitialAd 진입")
    }
    
    func removeAd() {
        //interstitialAd?.delegate = nil // delegate 해제
        self.adView.removeFromSuperview()
        print("removeInterstitialAd 진입")
    }

}

extension KeywordRegisterViewController {
//    func loadUserKeyword() {
//
//        if let userUid = UserDefaults.standard.string(forKey: "uid") {
//            db.collection("KeywordList").document(userUid).getDocument(completion: { documentSnapshot, error in
//                if let error = error {
//                    print("There was an issue saving data to firestore, \(error)")
//                } else {
//                    print("Keyword upload Done")
//                }
//            )
//
//            }
//        }
//    }
}

extension UIViewController {
    func alert1(title: String, message: String, actionTitle1: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: actionTitle1, style: .default)
        alertController.addAction(action1)
        self.present(alertController, animated: true)
    }
    
    func alert2(title: String, message: String, actionTitle1: String, actionTitle2: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: actionTitle1, style: .destructive)
        let action2 = UIAlertAction(title: actionTitle2, style: .default)
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
        
    }
}

extension KeywordRegisterViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        placeholderLabel.text = "불러온 뉴스가 없습니다"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .gray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if DataStore.shared.loadedKeywordSearchArray.count == 0 {
            DispatchQueue.main.async {
                tableView.backgroundView = placeholderLabel
                tableView.backgroundColor = .clear
                
                NSLayoutConstraint.activate([
                    placeholderLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    placeholderLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                ])
                //self.showAd()
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            print("광고 추적이 허용된 상태입니다. Tracking authorization status: Authorized")
                            // IDFA 가 활성화된 광고를 송출해야함
                            self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.keywordRegisterVCBannerAdwithIDFA, self.bannerView)
                            
                        case .denied:
                            print("광고 추적이 거부된 상태입니다. Tracking authorization status: Denied")
                            // 광고 추적이 거부된 상태입니다. 원하는 작업 수행

                            // IDFA 가 활성화되지 않은 광고를 송출해야함
                            self.setupBannerViewToBottom(adUnitID: Constants.GoogleAds.keywordRegisterVCBannerAdNOIDFA, self.bannerView)

                        case .restricted, .notDetermined:
                            print("권한이 제한되었거나 아직 결정되지 않았습니다. Tracking authorization status: Restricted or Not Determined")
                            
                        @unknown default:
                            print("Unknown authorization status")
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
                //self.removeAd()
                self.removeBanner(self.bannerView)
                
            }
        }
        return DataStore.shared.loadedKeywordSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = DataStore.shared.loadedKeywordSearchArray[indexPath.row]
        var contentUrl = selectedData[0].webSearchUrl
        
        //let selectedCell = tableView.cellForRow(at: indexPath)
        print("contentUrl: \(contentUrl)")
        if let URL = URL(string: (contentUrl)){
            print("URL :\(URL)")
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: URL, configuration: config)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet
            
            present(safariVC, animated: true, completion: nil)
        }
        searchTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        
        var inputName = DataStore.shared.loadedKeywordSearchArray[indexPath.row][0].name
        var inputQuery = DataStore.shared.loadedKeywordSearchArray[indexPath.row][0].query
        var inputDistributor = DataStore.shared.loadedKeywordSearchArray[indexPath.row][0].provider.name
        var inputDatePublished = DataStore.shared.loadedKeywordSearchArray[indexPath.row][0].datePublished
        var inputImage = DataStore.shared.loadedKeywordSearchArray[indexPath.row][0].image.contentUrl
        
        cell.titleLabel.text = inputName
        cell.distributorLabel.text = inputDistributor
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = inputFormatter.date(from: inputDatePublished) {
            let outputDatePublished = outputFormatter.string(from: date)
            cell.dateLabel.text = outputDatePublished
        } else {
            print("Invalid input string")
        }
        
        downloadImage(with: inputImage) { downloadedImage in
            DispatchQueue.main.async {
                if let image = downloadedImage {
                    cell.searchTableViewimageView.image = image
                    cell.searchTableViewimageView.contentMode = .scaleAspectFill
                    cell.searchTableViewimageView.clipsToBounds = true
                } else {
                    cell.searchTableViewimageView.image = UIImage(named: "AppIcon")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


