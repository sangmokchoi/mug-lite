//
//  BookmarkViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit
import SafariServices
import FBAudienceNetwork
import AdSupport
import AppTrackingTransparency

//let interstitialFBAD: FBInterstitialAd = FBInterstitialAd(placementID: "253023537370562_254136707259245")

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, FBAdViewDelegate, FBInterstitialAdDelegate {

    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    var adView: FBAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //requestPermission()
        
        // NotificationCenter에 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateBookmarkTableView), name: Notification.Name("updateBookmarkTableView"), object: nil)
        //print("DataStore.shared.bookmarkArray: \(DataStore.shared.bookmarkArray)")
        adView = FBAdView(placementID: "253023537370562_254136707259245", adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        adView.delegate = self
        
        //interstitialFBAD.delegate = self;
        adView.loadAd()
        
        DispatchQueue.main.async {
            //DataStore.shared.bookmarkArray = decodedData
            self.bookmarkTableView.reloadData()
        }
        configure()
    }
    
    private func configure() {
        bookmarkTableView.dataSource = self
        bookmarkTableView.delegate = self
        
        bookmarkTableView.separatorColor = UIColor(named: "AccentTintColor")
        bookmarkTableView.separatorInset.left = -50
        bookmarkTableView.separatorInset.right = -50
        
    }

    @objc func updateBookmarkTableView() {
        DispatchQueue.main.async {
            self.bookmarkTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.bookmarkArray = []
        loadBookmarkList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        placeholderLabel.text = "저장된 콘텐츠가 없습니다"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .gray
        
        if DataStore.shared.bookmarkArray.count == 0 {
            bookmarkTableView.backgroundView = placeholderLabel
        } else {
            bookmarkTableView.backgroundView = nil
        }
        return DataStore.shared.bookmarkArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell
        
        let indexPathRow = indexPath.row
        
        if indexPathRow < DataStore.shared.bookmarkArray.count {
            print("indexPathRow: \(indexPathRow) \nDataStore.shared.bookmarkArray[indexPathRow]: \(DataStore.shared.bookmarkArray.count)")
            var inputName = DataStore.shared.bookmarkArray[indexPathRow][0].name
            var inputQuery = DataStore.shared.bookmarkArray[indexPathRow][0].query
            var inputDistributor = DataStore.shared.bookmarkArray[indexPathRow][0].distributor
            var inputDatePublished = DataStore.shared.bookmarkArray[indexPathRow][0].datePublished
            
            cell.titleLabel.text = inputName
            cell.keywordLabel.text = "#\(inputQuery)"
            cell.distributorLabel.text = inputDistributor
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            if let date = outputFormatter.date(from: inputDatePublished) {
                //print("date: \(date)")
                let outputDatePublished = outputFormatter.string(from: date)
                //print("outputDatePublished: \(outputDatePublished)")
                cell.dateLabel.text = outputDatePublished
            } else {
                print("Invalid input string")
            }
        } else {
            print("Invalid index")
            print("indexPathRow: \(indexPathRow)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
        if editingStyle == .delete {
            DataStore.shared.bookmarkArray.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell
        let selectedData = DataStore.shared.bookmarkArray[indexPath.row]
        var contentUrl = selectedData[0].url
        
        //let selectedCell = tableView.cellForRow(at: indexPath)
        
        if let URL = URL(string: (contentUrl)){
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: URL, configuration: config)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet
            
            present(safariVC, animated: true, completion: nil)
        }
        bookmarkTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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

extension UIViewController {
//    func loadBookmarkList() {
//        print("loadBookmarkList() 진입")
//        if let userUid = UserDefaults.standard.string(forKey: "uid") {
//            print("if let userUid = UserDefaults.standard.string(forKey: uid) 진입")
//            var bookmarkArray : [APIData.Bookmarked] = []
//
//            let documentRef = db.collection("BookmarkList").document(userUid)
//
//            let listener = documentRef.addSnapshotListener { (documentSnapshot, error) in
//                guard let document = documentSnapshot else {
//                    print("Error fetching document: \(error)")
//                    return
//                }
//
//                if document.exists {
//                    if let bookmarkList = document.data()?["BookmarkList"] as? [[String: Any]] {
//
//                        var inputQuery = ""
//                        var inputUrl = ""
//                        var inputName = ""
//                        var inputDatePublished = ""
//                        var inputDistributor = ""
//
//                        for bookmarkDict in bookmarkList {
//                            // 각각의 요소에 접근하여 처리
//                            if let query = bookmarkDict["query"] as? String {
//                                print("Query: \(query)")
//                                inputQuery = query
//                            }
//                            if let url = bookmarkDict["url"] as? String {
//                                print("URL: \(url)")
//                                inputUrl = url
//                            }
//                            if let name = bookmarkDict["name"] as? String {
//                                print("name: \(name)")
//                                inputName = name
//                            }
//                            if let datePublished = bookmarkDict["datePublished"] as? String {
//                                print("datePublished: \(datePublished)")
//                                inputDatePublished = datePublished
//                            }
//                            if let distributor = bookmarkDict["distributor"] as? String {
//                                print("distributor: \(distributor)")
//                                inputDistributor = distributor
//                            }
//
//                            let bookmark = APIData.Bookmarked(
//                                query: inputQuery,
//                                url: inputUrl,
//                                name: inputName,
//                                datePublished: inputDatePublished,
//                                distributor: inputDistributor
//                            )
//                            bookmarkArray.append(bookmark)
//                            print("self.bookmarkArray.append: \(bookmarkArray)")
//                        }
//                    }
//                    DataStore.shared.bookmarkArray.append(bookmarkArray)
//                    print("DataStore.shared.bookmarkArray.append(self.bookmarkArray): \(DataStore.shared.bookmarkArray.count)")
//
//                    bookmarkArray = []
//                    print("self.bookmarkArray = []: \(bookmarkArray)")
//                    print("")
//                    print("Document exist and successfully loaded")
//                    DispatchQueue.main.async {
//                        NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
//                    }
//                } else {
//                    print("Document does not exist")
//                }
//            }
//            listener.remove()
//        } else {
//            print("no uid 즉, 로그인이 안되어 있음")
//        }
//    }
}

extension UIViewController {
    func loadBookmarkList() {
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            let documentRef = db.collection("BookmarkList").document(userUid)
            
            documentRef.getDocument { (documentSnapshot, error) in
                if let document = documentSnapshot, document.exists {
                    if let bookmarkList = document.data()?["BookmarkList"] as? [[String: Any]] {
                        var bookmarkArray : [APIData.Bookmarked] = []
                        
                        for bookmarkDict in bookmarkList {
                            // 각각의 요소에 접근하여 처리
                            if let query = bookmarkDict["query"] as? String,
                               let url = bookmarkDict["url"] as? String,
                               let name = bookmarkDict["name"] as? String,
                               let datePublished = bookmarkDict["datePublished"] as? String,
                               let distributor = bookmarkDict["distributor"] as? String {
                                
                                let bookmark = APIData.Bookmarked(
                                    query: query,
                                    url: url,
                                    name: name,
                                    datePublished: datePublished,
                                    distributor: distributor
                                )
                                bookmarkArray.append(bookmark)
                                DataStore.shared.bookmarkArray.append(bookmarkArray)
                                bookmarkArray = []
                            }
                        }
                        
                        // 기존의 데이터를 새로운 데이터로 업데이트
                        
                        print("Bookmark list successfully loaded")

                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            print("No uid, not logged in")
        }
    }
}

