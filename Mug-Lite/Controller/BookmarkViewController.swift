//
//  BookmarkViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit
import SafariServices
import AdSupport
import AppTrackingTransparency

//let interstitialFBAD: FBInterstitialAd = FBInterstitialAd(placementID: Constants.K.FBBannerAdPlacementID)

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //requestPermission()
        
        // NotificationCenter에 옵저버 등록
        //NotificationCenter.default.addObserver(self, selector: #selector(updateBookmarkTableView), name: Notification.Name("updateBookmarkTableView"), object: nil)
        //print("DataStore.shared.bookmarkArray: \(DataStore.shared.bookmarkArray)")
        
        DispatchQueue.main.async {
            //DataStore.shared.bookmarkArray = decodedData
            //self.bookmarkTableView.reloadData()
            self.bookmarkTableView.performBatchUpdates({
                let indexSet = IndexSet(integersIn: 0...0)
                self.bookmarkTableView.reloadSections(indexSet, with: UITableView.RowAnimation.automatic)
            }, completion: nil)
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
//        DispatchQueue.main.async {
//            //self.bookmarkTableView.reloadData()
//            self.bookmarkTableView.performBatchUpdates({
//                let indexSet = IndexSet(integersIn: 0...0)
//                self.bookmarkTableView.reloadSections(indexSet, with: UITableView.RowAnimation.none)
//            }, completion: nil)
//        }
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
            print("indexPathRow: \(indexPathRow) \nDataStore.shared.bookmarkArray.count: \(DataStore.shared.bookmarkArray.count)")
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
            print("itingStyle: UITableViewCell.EditingStyle, 진입")
            let bookmarkList = DataStore.shared.bookmarkArray[indexPath.row]
            updateBookmarkList(bookmarkList[0], indexPath.row)
            
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

//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
//                        }
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

extension BookmarkViewController {
    func updateBookmarkList(_ bookmarkList: APIData.Bookmarked, _ indexPathRow: Int) {
        print("updateBookmarkList 진입")
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(bookmarkList)
                
                guard let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    // JSON 변환에 실패한 경우 처리할 내용
                    return
                }
                
                // Firestore에 업로드
                let documentRef = db.collection("BookmarkList").document(userUid)
                
                documentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // 문서가 존재하는 경우, 기존 데이터를 불러오고, 이에 제거할 데이터만 제거하여 업데이트
                        var existingData = document.data()?["BookmarkList"] as? [[String: Any]] ?? []
                        
                        existingData.remove(at: indexPathRow)
                        documentRef.updateData(["BookmarkList": existingData]) { error in
                            if let error = error {
                                print("Error updating data in Firestore: \(error)")
                            } else {
                                print("Data updated successfully in Firestore")
                                self.alert1(title: "북마크 해제 완료", message: "북마크에서 해제되었습니다", actionTitle1: "확인")
                            }
                        }
                    } else {
                        // 문서가 존재하지 않는 경우, 새로운 문서 생성하여 업데이트
                        documentRef.setData(["BookmarkList": [jsonDict]]) { error in
                            if let error = error {
                                print("Error setting data in Firestore: \(error)")
                            } else {
                                print("Data set successfully in Firestore")
                            }
                        }
                    }
                }
            } catch {
                // 에러 핸들링
                print("Error encoding JSON data: \(error)")
            }
        }
    }
}
