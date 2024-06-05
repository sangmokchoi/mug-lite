//
//  AcrhiveViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//
import Foundation
import UIKit
import SafariServices
import AppTrackingTransparency
import AdSupport
import FirebaseAuth

//배너 광고 (Banner Ads): FBAdView 클래스를 사용하여 배너 광고를 표시할 수 있습니다.
//전면 광고 (Interstitial Ads): FBInterstitialAd 클래스를 사용하여 전면 광고를 표시할 수 있습니다.
//네이티브 광고 (Native Ads): FBNativeAd 클래스를 사용하여 네이티브 광고를 표시하고 사용자 지정할 수 있습니다.
//비디오 광고 (Video Ads): FBVideoAdsManager 클래스를 사용하여 비디오 광고를 표시하고 관리할 수 있습니다.
//인앱 광고 (In-Stream Ads): FBInStreamAd 클래스를 사용하여 인앱 광고를 표시할 수 있습니다.
//상품 카탈로그 광고 (Dynamic Product Ads): FBDynamicProductAd 클래스를 사용하여 동적 상품 카탈로그 광고를 표시할 수 있습니다.

class AcrhiveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var trendingNewsLabel: UILabel!
    @IBOutlet weak var trendingNewsRefreshButton: UIButton!
    
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let loadingIndicator_refresh = UIActivityIndicatorView(style: .medium)
    var isloadUserKeyword : Bool = false
    
    let mkt = "ko-KR"
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
    var count = 0
    var totalEstimatedResults = 0
    var buttonPressed = 0
    
    var bookmarkArray : [APIData.Bookmarked] = []
    
    let cellSpacingHeight : CGFloat = 1
    
    var titleImageButton = UIButton(type: .system)
    let adRowStep = 4
    
    //    var userUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "uid") != nil {
            print("uid가 있으므로 loadTrendingNews 진행")
            loadingIndicator.clipsToBounds = false
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.color = UIColor(named: "Main Color")
            loadingIndicator.backgroundColor = UIColor(named: "Main Color2")
            
            view.addSubview(loadingIndicator)
            view.bringSubviewToFront(loadingIndicator)
            
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: keywordCollectionView.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: keywordCollectionView.centerYAnchor),
            ])
            
            loadingIndicator.startAnimating()

            loadUserKeyword() {
                self.stopLoadingView()
            }
            
            loadTrendingNews() {
                
                DispatchQueue.main.async {
                    self.trendingCollectionView.performBatchUpdates({
                        print("self.trendingCollectionView.performBatchUpdates 진입")

                        let indexSet = IndexSet(integersIn: 0...0)
                        self.trendingCollectionView.reloadSections(indexSet)

                   }, completion: nil)
                }
                
            }
            
        }
        DataStore.shared.bookmarkArray = []
        //loadBookmarkList()
        
        configureButtonView()
        titleImageButton.addTarget(self, action: #selector(titleImageButtonTapped), for: .touchUpInside)
        
        keywordCollectionView.delegate = self
        keywordCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        
        keywordCollectionView.tag = 1
        trendingCollectionView.tag = 2
        
        trendingCollectionView.dragInteractionEnabled = false
        keywordCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingNewsRefreshButton.setTitle("", for: .normal)
        

        NotificationCenter.default.addObserver(self, selector: #selector(updateKeywordCollectionView), name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateKeywordCollectionViewAfterDeleteButtonPressed), name: Notification.Name("UpdateKeywordCollectionViewDeleteButtonPressed"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)
        
    }
    
    func stopLoadingView() {
        DispatchQueue.main.async {
            // Hide loading indicator
            print("stopLoadingView 진입")
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
            
            if !self.loadingIndicator.isAnimating {
                if DataStore.shared.userInputKeyword.isEmpty {
                    let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.keywordCollectionView.bounds.size.width, height: self.keywordCollectionView.bounds.size.height))
                    placeholderLabel.text = "키워드를 추가해보세요"
                    placeholderLabel.textAlignment = .center
                    placeholderLabel.textColor = .gray
                    
                    self.keywordCollectionView.backgroundView = placeholderLabel
                }
            }
            
        }
    }
    
    func loadVideoSearchArray(completion: @escaping () -> Void) {
        // 데이터 로딩 작업 수행
        if DataStore.shared.loadedVideoSearchArray.isEmpty {
            // 데이터가 없는 경우에 대한 처리
            print("No data found in loadedVideoSearchArray")
            completion()
            return
        }
        completion()
    }

    @objc func handleLoadTrendingNews() {
        loadTrendingNews {
            // 로드 완료 후 추가로 수행할 동작
            DispatchQueue.main.async {
                self.trendingCollectionView.performBatchUpdates({
                    print("self.trendingCollectionView.performBatchUpdates 진입")
                    
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.trendingCollectionView.reloadSections(indexSet)
                    
                }, completion: nil)
            }
        }
    }
    
    func loadTrendingNews(completion: @escaping () -> Void) { // 주요 기사 불러오기
        print("loadTrendingNews 진입")
        apiNewsSearch(query: Constants.K.headlineNews, count: 15, mkt: Constants.K.mkt, offset: DataStore.shared.newsOffsetForTrendingNews, keywordSearch: false, newsSearch: true) {
            print("loadTrendingNews apiNewsSearch 진입")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                print("DispatchQueue.main.asyncAfter 진입")
//                print("")
//                //self.trendingCollectionView.reloadData()
//                self.trendingCollectionView.performBatchUpdates({
//                    let indexSet = IndexSet(integersIn: 0...0)
//                    self.trendingCollectionView.reloadSections(indexSet)
//                }, completion: nil)
//                self.showAd()
//            }

            DispatchQueue.main.async {
                print("DispatchQueue.main.async 진입")
                //self.trendingCollectionView.reloadData()
                
            }
            completion()
            
        }
        
    }
    
    
//    let indexPath = IndexPath(item: 0, section: 0)
//    self.trendingCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    
    func scrollTrendingCollectionView(lastItem1: Int) { // offset 조정하기
        
        DispatchQueue.main.async {
            
            self.trendingCollectionView.performBatchUpdates({
                print("self.trendingCollectionView.performBatchUpdates 진입")

                let indexSet = IndexSet(integersIn: 0...0)
                self.trendingCollectionView.reloadSections(indexSet)

            }, completion: { _ in
                //self.trendingCollectionView.reloadData()
                               
                let indexPath = IndexPath(item: lastItem1, section: 0)
                
                self.trendingCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                
                self.loadingIndicator_refresh.stopAnimating()
                self.loadingIndicator_refresh.removeFromSuperview()
            })
            
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //requestPermission()
        
        configureButtonView()
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        registerXib()
        
        if UserDefaults.standard.string(forKey: "uid") != nil {
            print("uid가 있으므로 loadTrendingNews 진행")
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleLoadTrendingNews), name: Notification.Name("loadTrendingNews"), object: nil)
        }
        
        
        DispatchQueue.main.async {
            self.trendingCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermission() //여기서 추후에 요청해야 함
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //requestPermission()
    }
    
    @objc func updateKeywordCollectionView() {
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
            //self.requestPermission()
        }
    }
    
    @objc func updateKeywordCollectionViewAfterDeleteButtonPressed() {
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
        }
    }
    
    private func configureButtonView() {
        
        let titleImageView = UIImageView(image: UIImage(named: "Image"))
        
        //titleImageButton.backgroundColor = .black
        titleImageButton.addSubview(titleImageView)
        self.view.addSubview(titleImageButton)
        
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        titleImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        titleImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleImageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -10).isActive = true
        titleImageButton.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 15).isActive = true
        titleImageButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        titleImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        titleImageButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        titleImageButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    @objc private func titleImageButtonTapped() {
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            self.tabBarController?.selectedIndex = 3
            // 회원정보를 보여주는게 낫지 않나?
            //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //            let SignupViewController = storyboard.instantiateViewController(identifier: "SignupViewController")
            //            SignupViewController.modalPresentationStyle = .automatic
            //            self.show(SignupViewController, sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SignupViewController = storyboard.instantiateViewController(identifier: "SignupViewController")
            SignupViewController.modalPresentationStyle = .automatic
            self.show(SignupViewController, sender: nil)
        }
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        let nibName1 = UINib(nibName: "CustomizedCollectionViewCell", bundle: nil)
        trendingCollectionView.register(nibName1, forCellWithReuseIdentifier: "CustomizedCollectionViewCell")
        
        let nibName2 = UINib(nibName: "KeywordCollectionViewCell", bundle: nil)
        keywordCollectionView.register(nibName2, forCellWithReuseIdentifier: "KeywordCollectionViewCell")
        
    }
    
    func applyShadowEffect(to cell: UICollectionViewCell) {
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
    }
        
    func removeShadowEffect(from cell: UICollectionViewCell) {
        cell.layer.shadowOpacity = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        let userPoint = UserDefaults.standard.integer(forKey: "point")
        let userUid = UserDefaults.standard.string(forKey: "uid")
        if userUid == nil || userUid == "" { // 현재 로그아웃 시에는 클릭이 가능한 상황이라 수정 필요
            loginAlert()
        } else {
            if collectionView.tag == 1 { // 키워드 추가
                if indexPath.row == 0 { // '키워드 추가' 버튼
                    performSegue(withIdentifier: "ArchiveToKeywordRegister", sender: self)
                    //self.tabBarController?.selectedIndex = 1
                } else { // 세그할 때, 클릭한 셀의 키워드 이름을 전달하고, 그 키워드 이름으로 api 콜을 실행해야 함.
                    
                    // 클릭 시에 그림자 효과 적용 필요
                    if let selectedCell = keywordCollectionView.cellForItem(at: indexPath) as? KeywordCollectionViewCell {
                        
                        // 가져온 셀의 clickCount를 판단
                        if selectedCell.clickCount == 0 {
                            selectedCell.clickCount = 1
                        } else {
                            
                        }
      
                        if let query = selectedCell.keywordLabel.text {
                            if (userPoint - Constants.K.refreshCost) < 0 {
                                // 포인트가 없으므로 충전해야됨
                                settingVCAlert()
                                DispatchQueue.main.async {
                                    self.loadingIndicator_refresh.stopAnimating()
                                    self.loadingIndicator_refresh.removeFromSuperview()
                                }
                            } else {
                                DataStore.shared.totalSearch = []
                                // 클릭과 동시에 API 콜 시작
                                apiNewsSearch(query: query, count: 20, mkt: Constants.K.mkt, offset: DataStore.shared.newsOffsetForKeyword, keywordSearch: false, newsSearch: false) {
                                    //apiVideoSearch(query: query, count: 10, mkt: Constants.K.mkt, offset: 0)
                                }
                                
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "ArchiveToReading", sender: indexPath.row)
                                }
                            }
                        }
                    }
                }
            } else { // 주요기사
                if DataStore.shared.loadedNewsSearchArray.count != 0 { // 불러올 오늘의 주요기사가 있는 경우

                    if indexPath.row == 1 { // 광고 삽입되는 셀
                        print("불러올 오늘의 주요기사가 있는 경우 광고 삽입되는 셀")
                        if let URL = URL(string: "https://sites.google.com/view/howtouse-mug-lite/%ED%99%88"){
                            let safariVC = SFSafariViewController(url: URL)
                            safariVC.transitioningDelegate = self
                            safariVC.modalPresentationStyle = .pageSheet
                            
                            present(safariVC, animated: true, completion: nil)
                        }
                    } else {
                        print("불러올 오늘의 주요기사가 있는 경우 광고 삽입 안되는 셀")
                        let selectedCell = trendingCollectionView.cellForItem(at: indexPath) as? CustomizedCollectionViewCell
                        if let URL = URL(string: (selectedCell?.clearUrlLabel.text)!){
                            let config = SFSafariViewController.Configuration()
                            config.entersReaderIfAvailable = true
                            let safariVC = SFSafariViewController(url: URL, configuration: config)
                            safariVC.transitioningDelegate = self
                            safariVC.modalPresentationStyle = .pageSheet
                            
                            present(safariVC, animated: true, completion: nil)
                        }
                    }
                } else { // 불러올 오늘의 주요기사가 없는 경우
                    print("불러올 오늘의 주요기사가 없는 경우")
                    if let URL = URL(string: "https://sites.google.com/view/howtouse-mug-lite/%ED%99%88"){
                        let safariVC = SFSafariViewController(url: URL)
                        safariVC.transitioningDelegate = self
                        safariVC.modalPresentationStyle = .pageSheet
                        
                        present(safariVC, animated: true, completion: nil)
                    }
                }
                
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArchiveToReading" {
            let nextVC = segue.destination as? ReadingViewController
            
            if let index = sender as? Int {
                let selectedCell = keywordCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? KeywordCollectionViewCell
                nextVC?.query = selectedCell?.keywordLabel.text
                print("nextVC?.query: \(selectedCell?.keywordLabel.text)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 { // 키워드 관리 컬렉션 뷰
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        
        if collectionView.tag == 1 { // 키워드 관리 컬렉션 뷰
            let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCollectionViewCell", for: indexPath) as! KeywordCollectionViewCell
            
            DispatchQueue.main.async {
                NSLayoutConstraint.activate([
                    cell.ellipseView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 25), // 20
                    cell.ellipseView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -25), //-30
                    
                    cell.firstLetterLabel.centerXAnchor.constraint(equalTo: cell.ellipseView.centerXAnchor),
                    cell.firstLetterLabel.centerYAnchor.constraint(equalTo: cell.ellipseView.centerYAnchor)
                ])
            }
            
            let imageArray = ["Ellipse Blue", "Ellipse Green", "Ellipse Orange", "Ellipse Red", "Ellipse Sky", "Ellipse Yellow"]
            let randomNumber = arc4random_uniform(6)
            
            let image = UIImage(named: imageArray[Int(randomNumber)])
            
            // cell[indexPath.row = 0]은 반드시 키워드 추가 버튼으로 되어야 함
            if DataStore.shared.userInputKeyword != [] { // DataStore.shared에 데이터가 있으므로 그대로 키워드를 불러오면 됨
                if indexPath.row == 0 {
                    cell.ellipseView.image = UIImage(named: "keywordAdd")
                    cell.firstLetterLabel.text = "+"
                    cell.keywordLabel.text = "키워드 추가"
                    
                } else {
                    let keyword = DataStore.shared.userInputKeyword[indexPath.row-1]
                    if keyword.first != nil {
                        let firstLetter = String(describing: keyword.first!) // 빈칸만 넣으면 옵셔널 에러가 발생하므로 빈칸, 특수기호만을 넣지 않도록 유도 필요
                        cell.configure(withImage: image, keyword: keyword, firstLetter: firstLetter)
                    } else {
                        alert1(title: "입력한 키워드가 없어요", message: "키워드를 입력해주세요", actionTitle1: "확인")
                    }
                }
            } else { // DataStore.shared.userInputKeyword == [] //DataStore.shared에 데이터가 없으므로 placeholder를 노출해야 됨.
                
                if indexPath.row == 0 {
                    cell.configure(withImage: UIImage(named: "keywordAdd"), keyword: "키워드 추가", firstLetter: "+")
                } else {
                    // 추가적인 처리를 할 경우를 대비해 기본값 설정
                    cell.configure(withImage: UIImage(named: "keywordAdd"), keyword: "키워드 추가", firstLetter: "+")
                }
            }
            
            return cell
            
        } else { // 오늘의 주요 기사
            let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomizedCollectionViewCell", for: indexPath) as! CustomizedCollectionViewCell
            
            DispatchQueue.main.async {
                cell.contentView.translatesAutoresizingMaskIntoConstraints = false
                cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentTextView.contentOffset = .zero
            }

            if DataStore.shared.loadedNewsSearchArray.count != 0 { // 자료가 들어와 있는 상태
                if indexPath.row == 1 { // 광고 삽입되는 셀
                    
                    cell.dateLabel.text = ""
                    cell.queryLabel.text = ""
                    cell.distributorLabel.text = ""
                    cell.thumbnailImageView.image = nil
                    cell.contentTextView.text = ""
                    
//                    if adView.isAdValid == true {
//                        print("cellForItemAt 진입")
//                        adView.backgroundColor = UIColor(named: "Main Color2")
//                        
//                        cell.containerView.addSubview(adView)
//                        cell.contentView.addSubview(cell.containerView)
//                        cell.contentView.bringSubviewToFront(cell.containerView)
//                        
//                        return cell
//                        
//                    } else {
                        cell.thumbnailImageView.backgroundColor = UIColor(named: "Dark Grey")
                        cell.thumbnailImageView.image = UIImage(named: "Image")
                        cell.thumbnailImageView.contentMode = .scaleAspectFit

                        cell.contentTextView.text = "mug-lite로\n오늘의 뉴스를 만나보세요"
                        cell.contentTextView.font = .systemFont(ofSize: 20, weight: .medium)
                        cell.contentTextView.tintColor = .white
                        cell.contentTextView.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
                        cell.contentTextView.layer.cornerRadius = 10
                        cell.contentTextView.textAlignment = .center
                        
                        return cell
                    //}

                } else if indexPath.row < 1 { // 광고 삽입 이전의 셀
                    let firstArray = DataStore.shared.loadedNewsSearchArray[indexPath.row]
                    imageViewSet(cell: cell, firstArray: firstArray)
                    
                    return cell
                    
                } else { // 광고 삽입 이후의 셀
                    let firstArray = DataStore.shared.loadedNewsSearchArray[indexPath.row-1]
                    imageViewSet(cell: cell, firstArray: firstArray)
                    
                    return cell
                }
            } else { // 자료가 들어와 있지 않는 상태
                
                cell.thumbnailImageView.backgroundColor = UIColor(named: "Dark Grey")
                cell.thumbnailImageView.image = UIImage(named: "Image")
                cell.thumbnailImageView.contentMode = .scaleAspectFit
            
                //cell.thumbnailImageView.image = UIImage(named: "Ellipse Black")
                cell.contentTextView.text = "mug-lite로\n오늘의 뉴스를 만나보세요"
                cell.contentTextView.font = .systemFont(ofSize: 20, weight: .medium)
                cell.contentTextView.tintColor = .white
                cell.contentTextView.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
                cell.contentTextView.layer.cornerRadius = 10
                cell.contentTextView.textAlignment = .center
                
                cell.dateLabel.text = ""
                cell.queryLabel.text = ""
                cell.distributorLabel.text = ""
                
                return cell
            }
            //cell.contentTextView?.text = firstArray[0].description
            //cell.urlButton?.titleLabel?.text = firstArray[0].webSearchUrl
            //cell.selectionStyle = UITableViewCell.SelectionStyle.none
            //navigationController?.navigationBar.sizeToFit()
        }
    }
    
    @IBAction func trendingNewsRefreshButtonPressed(_ sender: UIButton) {
        
        var userPoint = UserDefaults.standard.integer(forKey: "point")
        let userUid = UserDefaults.standard.string(forKey: "uid")
        
        if userUid == nil || userUid == "" {
            loginAlert() // userUid가 nil 또는 ""인 경우, 알림 창을 띄웁니다.
        } else {
            loadingIndicator_refresh.clipsToBounds = false
            loadingIndicator_refresh.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator_refresh.backgroundColor = UIColor(named: "Main Color2")
            
            view.addSubview(loadingIndicator_refresh)
            view.bringSubviewToFront(loadingIndicator_refresh)
            
            NSLayoutConstraint.activate([
                loadingIndicator_refresh.centerXAnchor.constraint(equalTo: trendingNewsRefreshButton.centerXAnchor),
                loadingIndicator_refresh.centerYAnchor.constraint(equalTo: trendingNewsRefreshButton.centerYAnchor),
                loadingIndicator_refresh.trailingAnchor.constraint(equalTo: trendingNewsRefreshButton.leadingAnchor, constant: 60)
            ])
            loadingIndicator_refresh.startAnimating()
            
            let currentDate = Date()
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: Locale.current.identifier)
            calendar.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
            
            if let previousDate = UserDefaults.standard.object(forKey: "previousDate") as? Date,
                let buttonPressed = UserDefaults.standard.object(forKey: "buttonPressed") as? Int { // 버튼이 눌린 적이 있는 상태
                
                let previousDateComponents = calendar.dateComponents([.day], from: previousDate)
                let currentDateComponents = calendar.dateComponents([.day], from: currentDate)
                print("previousDateComponents: \(previousDateComponents)")
                print("currentDateComponents: \(currentDateComponents)")
                
                if previousDateComponents.day != currentDateComponents.day {
                    // Reset the buttonPressed variable and update the previousDate in UserDefaults
                    UserDefaults.standard.set(currentDate, forKey: "previousDate")
                    self.buttonPressed = 1
                    
                    UserDefaults.standard.set(self.buttonPressed, forKey: "buttonPressed")
                    print("self.buttonPressed: \(self.buttonPressed)")
                    
                    clearTrendingCollectionView()
                    loadTrendingNews() {
                        
                        DispatchQueue.main.async { // 하루 최대 3개까지 부여
                            let lastItem1 = self.trendingCollectionView.numberOfItems(inSection: 0)
                            self.scrollTrendingCollectionView(lastItem1: lastItem1)
                            self.pointUpdate(newUserPoint: -150) {
                                print("pointUpdate 1번째")
                            }
                        }
                    }
                } else { // previousDateComponents.day == currentDateComponents.day 동일한 날짜임 (3이 넘어가면, 새로고침이 안되어야 하는 날)
                    
                    self.buttonPressed = buttonPressed

                    if self.buttonPressed < 3 {
                        if (userPoint - Constants.K.refreshCost) < 0 {
                            // 포인트가 없으므로 충전해야됨
                            settingVCAlert()
                            DispatchQueue.main.async {
                                self.loadingIndicator_refresh.stopAnimating()
                                self.loadingIndicator_refresh.removeFromSuperview()
                            }
                        } else {
                            self.buttonPressed += 1 // 다음 날이 되면 buttonPressed가 0이 되어야 함
                            print("buttonPressed: \(self.buttonPressed)")
                            // 셀 초기화 및 데이터 업데이트
                            
                            clearTrendingCollectionView()
                            loadTrendingNews() {
                                
                                DispatchQueue.main.async { // 하루 최대 3개까지 부여
                                    let lastItem1 = self.trendingCollectionView.numberOfItems(inSection: 0)
                                    self.scrollTrendingCollectionView(lastItem1: lastItem1)
                                    self.pointUpdate(newUserPoint: -150) {
                                        print("pointUpdate 2번째")
                                    }
                                }
                            }
                        }
                    } else {
                        alert1(title: "오늘의 주요 기사 새로고침은\n하루 최대 3회입니다", message: "관심 있는 키워드를 찾아보는 건 어떨까요?", actionTitle1: "확인")
                        DispatchQueue.main.async {
                            self.loadingIndicator_refresh.stopAnimating()
                            self.loadingIndicator_refresh.removeFromSuperview()
                        }
                    }
                    UserDefaults.standard.set(self.buttonPressed, forKey: "buttonPressed")
                    print("self.buttonPressed: \(self.buttonPressed)")
                }
                
            } else { // 버튼이 처음 눌린 상태
                if (userPoint - Constants.K.refreshCost) < 0 {
                    // 포인트가 없으므로 충전해야됨
                    settingVCAlert()
                    DispatchQueue.main.async {
                        self.loadingIndicator_refresh.stopAnimating()
                        self.loadingIndicator_refresh.removeFromSuperview()
                    }
                } else { // 포인트가 있음
                    UserDefaults.standard.set(currentDate, forKey: "previousDate")
                    self.buttonPressed = 1
                    
                    UserDefaults.standard.set(self.buttonPressed, forKey: "buttonPressed")
                    print("buttonPressed: \(self.buttonPressed)")
                    
                    clearTrendingCollectionView()
                    loadTrendingNews() {
                        
                        DispatchQueue.main.async { // 하루 최대 3개까지 부여
                            let lastItem1 = self.trendingCollectionView.numberOfItems(inSection: 0)
                            self.scrollTrendingCollectionView(lastItem1: lastItem1)
                            self.pointUpdate(newUserPoint: -150) {
                                print("pointUpdate 3번째")
                            }
                        }
                    }
                }
            }

            UserDefaults.standard.set(self.buttonPressed, forKey: "buttonPressed")
        }
    }
    
    func clearTrendingCollectionView() {
        // trendingCollectionView의 데이터를 초기화
        DataStore.shared.loadedVideoSearchArray = []
        // trendingCollectionView 리로드
//        DispatchQueue.main.async {
//            //self.trendingCollectionView.reloadData()
//            self.trendingCollectionView.performBatchUpdates({
//                let indexSet = IndexSet(integersIn: 0...0)
//                self.trendingCollectionView.reloadSections(indexSet)
//            }, completion: nil)
//        }
        
    }
    
}

extension UIViewController {
    
    func requestPermission() {
         if #available(iOS 14, *) {
             ATTrackingManager.requestTrackingAuthorization { status in
                 switch status {
                 case .authorized:
                     // Tracking authorization dialog was shown
                     // and we are authorized
                     print("Authorized")

                     // Now that we are authorized we can get the IDFA
                     print(ASIdentifierManager.shared().advertisingIdentifier)
                 case .denied:
                     // Tracking authorization dialog was
                     // shown and permission is denied
                     print("Denied")
                 case .notDetermined:
                     // Tracking authorization dialog has not been shown
                     print("Not Determined")
                     // Request authorization again
                     DispatchQueue.main.async {
                         self.requestPermission()
                     }
                 case .restricted:
                     print("Restricted")
                 @unknown default:
                     print("Unknown")
                 }
             }
         }
     }
}

//MARK: - FB NATIVE AD SETTING
extension AcrhiveViewController {

//    private func cellForAd(at indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomizedCollectionViewCell", for: indexPath) as! CustomizedCollectionViewCell
//
//        // 광고 뷰를 셀의 하위 뷰로 추가
//        cell.addSubview(adView)
//
//        // 광고 셀의 크기 및 레이아웃 설정
//        cell.frame = CGRect(x: cell.bounds.minX, y: cell.bounds.minY, width: cell.bounds.width, height: cell.bounds.height)// 원하는 크기와 위치로 설정
//
//        return cell
//    }
}
//extension AcrhiveViewController : FBNativeAdDelegate, FBNativeAdsManagerDelegate {

//    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
//        //FBnativeAdView.title
//        //FBnativeAdView.body
//        //FBnativeAdView.iconImage
//
//        let attributes = FBNativeAdViewAttributes()
//        attributes.buttonColor = .blue
//        attributes.buttonTitleColor = .brown
//        attributes.backgroundColor = .darkGray
//        attributes.titleColor = .gray
//        attributes.descriptionColor = .blue
//
//        let nativeAdView = FBNativeAdView(nativeAd: nativeAd, with: FBNativeAdViewType.genericHeight300, with: attributes)
//        nativeAdView.isHidden = false
//        nativeAdView.frame = CGRectMake(20.0, 100.0, view.bounds.size.width - 40.0, 300.0)
//
//        let coverMediaView = FBMediaView()
//        coverMediaView.frame = CGRect(x: 0, y: 0, width: nativeAdView.bounds.width, height: 200) // 적절한 프레임 크기로 조정해야 합니다.
//
//        let screenHeight = view.bounds.height
//        let adViewHeight = nativeAdView.bounds.height
//        //FBnativeAdView.registerView(forInteraction: nativeAdView, mediaView: coverMediaView, iconView: coverMediaView, viewController: self)
//        //
//
//        print("adViewDidLoad 성공")
//        self.view.addSubview(nativeAdView)
//
//        // FBnativeAdView.registerView(forInteraction: nativeAdView, mediaView: coverMediaView, iconView: nil, viewController: self)
//
//    }

    
//    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
//        print("광고 불러오기 실패: \(error)")
//        print("FBAdSettings.isTestMode: \(FBAdSettings.isTestMode() )")
//        print("FBAdSettings.testDeviceHash \(FBAdSettings.testDeviceHash())")
//    }
    
//    func configureAdManagerAndLoadAds() {
//        if adsManager == nil {
//            adsManager = FBNativeAdsManager(placementID: Constants.K.FBNativeAdPlacementID, forNumAdsRequested: 5)
//            adsManager.delegate = self
//            adsManager.loadAds()
//        }
//    }
    
//    func nativeAdsLoaded() {
//        print("nativeAdsLoaded 진입")
//        adsCellProvider = FBNativeAdCollectionViewCellProvider(manager: adsManager, for: FBNativeAdViewType.genericHeight300)
//        adsCellProvider.delegate = self
//    }
//
//    func nativeAdsFailedToLoadWithError(_ error: Error) {
//        print("nativeAdsFailedToLoadWithError 진입")
//        print("nativeAdsFailedToLoadWithError: \(error)")
//    }
//
//    func nativeAdDidClick(nativeAd: FBNativeAd) {
//        print("nativeAdDidClick 진입")
//    }
    
//}

extension AcrhiveViewController {
    
    func imageViewSet(cell: CustomizedCollectionViewCell, firstArray : [APIData.webNewsSearch]){
        var imageUrl = firstArray[0].image.contentUrl ?? ""// UIImage(named: "AppIcon")
        var imageWidth = firstArray[0].image.width
        var imageHeight = firstArray[0].image.height
        var inputDate = firstArray[0].datePublished
        var title = firstArray[0].name
        var distributor = firstArray[0].provider.name
        var contentUrl = firstArray[0].webSearchUrl
        var content = firstArray[0].description
        
        var image: UIImage?
        
        cell.queryLabel.text = "#\(Constants.K.headlineNews)"
        cell.contentTextView.text = title
        cell.contentTextView.tag = 1
        cell.contentTextView.font = .systemFont(ofSize: 20, weight: .semibold)
        cell.contentTextView.contentOffset = .zero
        cell.distributorLabel.text = distributor
        //cell.subContentTextView.text = ""
        //cell.clearUrlLabel.text = contentUrl
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = inputFormatter.date(from: inputDate) {
            let outputDate = outputFormatter.string(from: date)
            cell.dateLabel.text = outputDate
            //print("imageWidth: \(imageWidth), imageHeight: \(imageHeight)")
        } else {
            print("Invalid input string")
        }
        
        if imageUrl.isEmpty { // imageUrl이 없는 경우 기본 이미지인 "AppIcon"을 사용
            image = UIImage(named: "AppIcon")
            updateUI(with: image, in: cell, imageHeight: imageHeight, imageWidth: imageHeight)
        } else {
            if let url = URL(string: imageUrl) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data else {
                        print("Error: No image data.")
                        return
                    }
                    // 다운로드한 데이터를 UIImage로 변환
                    guard let downloadedImage = UIImage(data: data) else {
                        print("Error: Cannot convert data to image.")
                        return
                    }
                    
                    let noiseReducedImage = self.Image_ReduceNoise(image: downloadedImage)
                    let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
                    
                    DispatchQueue.main.async {
                        image = sharpnessEnhancedImage
                        self.updateUI(with: image, in: cell, imageHeight: imageHeight, imageWidth: imageHeight)
                    }
                }
                task.resume()
            } else {
                // 이미지 다운로드에 실패한 경우 기본 이미지인 "AppIcon"을 사용
                image = UIImage(named: "AppIcon")
                updateUI(with: image, in: cell, imageHeight: imageHeight, imageWidth: imageHeight)
            }
        }
        
        DispatchQueue.main.async {
            // 하단 그라디언트 추가
            let newView1 = UIView()
            newView1.frame = cell.bounds
            newView1.setGradient(color1: .clear, color2: .black, location1: 0.0, location2: 0.6, location3: 1.0, startPoint1: 0.5, startPoint2: 0.5, endPoint1: 0.5, endPoint2: 1.0)
            
            cell.containerView1.addSubview(newView1)
            
            // 상단 그라디언트 추가
            let newView2 = UIView()
            newView2.frame = cell.bounds
            newView2.setGradient(color1: .black, color2: .clear, location1: 0.0, location2: 0.5, location3: 1.0, startPoint1: 0.5, startPoint2: 0.0, endPoint1: 0.5, endPoint2: 0.5)
            
            cell.containerView1.addSubview(newView2)
            
            cell.contentView.addSubview(cell.containerView)
            cell.contentView.sendSubviewToBack(cell.containerView)
            
            cell.contentView.addSubview(cell.containerView1)
            cell.contentTextView.sendSubviewToBack(cell.containerView1)
            //cell.subContentTextView.sendSubviewToBack(cell.containerView1)
            
            cell.contentView.bringSubviewToFront(cell.contentTextView)
            cell.contentView.bringSubviewToFront(cell.verticalStackView)
            
            //cell.bookmarkButton = nil
            let bookmarkButton = UIButton(type: .system)
            bookmarkButton.backgroundColor = .clear
            bookmarkButton.tag = 3
            cell.bookmarkButton = bookmarkButton
        
            if let bookmarkImage = UIImage(systemName: "bookmark")?.withTintColor(.white, renderingMode: .alwaysTemplate), let bookmarkFillImage = UIImage(systemName: "bookmark.fill")?.withTintColor(.white, renderingMode: .alwaysTemplate) {
                
                // 여기에서 url 여부에 따라 버튼의 이미지를 결정해야 함
                bookmarkButton.setImage(bookmarkImage, for: .normal)
                bookmarkButton.tintColor = .white
                bookmarkButton.tag = 11
                
//                if self.bookmarkUrlCheck(contentUrl) == true { // true 이므로 저장된 북마크가 있음
//                    //print("true 이므로 저장된 북마크가 있음")
//                    bookmarkButton.setImage(bookmarkFillImage, for: .normal)
//                    bookmarkButton.tintColor = .white
//                    bookmarkButton.tag = 10
//                } else { // false 이므로 저장된 북마크가 없음
//                    //print("false 이므로 저장된 북마크가 없음")
//                    bookmarkButton.setImage(bookmarkImage, for: .normal)
//                    bookmarkButton.tintColor = .white
//                    bookmarkButton.tag = 11
//                }
            }
            
            let bookmarkButtonWidth = 80
            bookmarkButton.frame = CGRect(
                x: Int(cell.bounds.maxX) - 70,
                y: Int(cell.contentView.bounds.minY) + 5,
                width: bookmarkButtonWidth,
                height: 60)
            
            bookmarkButton.addTarget(self, action: #selector(self.bookmarkButtonPressed(_:)), for: .touchUpInside)
            
            let distributorLabel = UILabel()
            distributorLabel.text = distributor
            distributorLabel.backgroundColor = .clear
            distributorLabel.textColor = .clear
            distributorLabel.tag = 1
            
            let dateLabel = UILabel()
            dateLabel.text = cell.dateLabel.text
            dateLabel.backgroundColor = .clear
            dateLabel.textColor = .clear
            dateLabel.tag = 2
            
            let contentUrlLabel = UILabel()
            contentUrlLabel.text = contentUrl
            contentUrlLabel.backgroundColor = .clear
            contentUrlLabel.textColor = .clear
            contentUrlLabel.tag = 3
            
            cell.contentView.addSubview(distributorLabel)
            cell.contentView.addSubview(dateLabel)
            cell.contentView.addSubview(contentUrlLabel)
            cell.contentView.addSubview(bookmarkButton)
        
        }
    }
    
    func updateUI(with image: UIImage?, in cell: CustomizedCollectionViewCell, imageHeight: Int, imageWidth: Int) { // 이미지 업데이트만 처리
        // UI 업데이트는 메인 스레드에서 처리
        
        let backgroundImageView = UIImageView(image: image) // 배경으로 블러 처리할 이미지 불러오기
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
        
        backgroundImageView.frame = cell.bounds
        viewBlurEffect.frame = backgroundImageView.frame
        
        for subview in backgroundImageView.subviews { // 배경에 넣기 전 배경 초기화
            subview.removeFromSuperview()
        }
        
        cell.containerView.addSubview(backgroundImageView)
        cell.containerView.addSubview(viewBlurEffect)
        
        cell.thumbnailImageView.clipsToBounds = true
        
        if imageHeight == 0 || imageWidth == 0 {
            cell.thumbnailImageView.contentMode = .scaleAspectFit
            print("imageHeight: \(imageHeight)")
            print("imageWidth: \(imageWidth)")
            
            if image != UIImage(named: "AppIcon") && image != UIImage(named: "Image") { // 앱 아이콘으로 설정되지 않은 경우
                print("1. 뷰의 프레임 크기를 디바이스 화면 크기의 1/8로 설정")
                cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = true
                cell.thumbnailImageView.removeConstraints(cell.thumbnailImageView.constraints)

                let thumbnailSize = CGSize(width: cell.contentView.frame.width / 6, height: cell.contentView.frame.height / 6)
                let xPosition = (cell.contentView.frame.width - thumbnailSize.width) / 2
                let yPosition = (cell.contentView.frame.height - thumbnailSize.height) / 2

                cell.thumbnailImageView.contentMode = .scaleAspectFit
                cell.thumbnailImageView.frame = CGRect(x: xPosition, y: yPosition, width: thumbnailSize.width, height: thumbnailSize.height)
                
                cell.thumbnailImageView.contentMode = .scaleAspectFit
                cell.thumbnailImageView.image = image?.withRenderingMode(.alwaysOriginal) // 배경을 투명하게 처리하기 위해 withRenderingMode 설정
                
                // 추가적인 배경 처리를 위해 이미지 뷰의 배경색을 투명하게 설정
                cell.thumbnailImageView.backgroundColor = .clear
                cell.thumbnailImageView.layer.masksToBounds = true // 이미지가 이미지 뷰를 벗어나는 부분을 잘라냄
                cell.thumbnailImageView.image = image
                
            } else { // 앱 아이콘으로 설정된 경우
                print("앱 아이콘")
                cell.thumbnailImageView.image = image
            }
        } else {
            cell.thumbnailImageView.contentMode = .scaleAspectFit
            cell.thumbnailImageView.image = image
        }
        cell.contentTextView.textContainer.maximumNumberOfLines = 3
        cell.contentTextView.contentOffset = .zero
        cell.contentTextView.textContainer.lineBreakMode = .byTruncatingTail
    }
    
//    func bookmarkUrlCheck(_ url: String) -> Bool {
//        // 1.url이 북마크에 저장된 적이 있는지 확인
//        // ( url을 DataStore.shared.bookmarkArray에 조회해서 DataStore.shared.totalSearch의 webSearchUrl에 존재하는지 확인)
//        var isStringUrl = false
//
//        for i in 0..<DataStore.shared.bookmarkArray.count {
//            let urlCheck = DataStore.shared.bookmarkArray[i][0].url
//            let urlName = DataStore.shared.bookmarkArray[i][0].name
//
//            //print("urlName: \(urlName)")
//            if url == urlCheck {
//                isStringUrl = true // 저장된 북마크 있음
//                //print("저장된 북마크 있음 isStringUrl: \(isStringUrl)")
//                return isStringUrl
//            } else {
//                isStringUrl = false
//                //print("저장된 북마크 없음 isStringUrl: \(isStringUrl)")
//            }
//        }
//
//        return isStringUrl
//    }
    
    @objc internal func bookmarkButtonPressed(_ sender: Any) {
        let userUid = UserDefaults.standard.string(forKey: "uid")
        if userUid == nil || userUid == "" {
            // userUid가 nil 또는 ""인 경우, 알림 창을 띄웁니다.
            loginAlert()
        } else {
            let bookmarkFillImage = UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysTemplate)
            let bookmarkImage = UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate)
            
            if let button = sender as? UIButton {
                
                if let superview = button.superview {
                    
                    var titleText = ""
                    var distributorText = ""
                    var dateText = ""
                    var urlText = ""
                    
                    for subview in superview.subviews {
                        if let label = subview as? UILabel {
                            switch label.tag {
                            case 1: // distributor
                                distributorText = label.text ?? ""
                                //print("distributorText: \(distributorText)")
                            case 2: // date
                                dateText = label.text ?? ""
                                //print("dateText: \(dateText)")
                            case 3: // url
                                urlText = label.text ?? ""
                                //print("urlText: \(urlText)")
                            default:
                                break
                            }
                        } else if let contentTextView = subview as? UITextView {
                            switch contentTextView.tag {
                            case 1: // contentTextView
                                titleText = contentTextView.text ?? ""
                                //print("titleText: \(titleText)")
                            case 2: // subContentTextView
                                print("")
                                //titleText = contentTextView.text ?? ""
                            default:
                                break
                            }
                        }
                    }
                    // APIData.Bookmarked에 값을 할당하여 bookmarkArray에 추가
                    let bookmark = APIData.Bookmarked(
                        query: Constants.K.headlineNews,
                        url: urlText,
                        name: titleText,
                        datePublished: dateText,
                        distributor: distributorText
                    )
                    
                    if button.image(for: .normal) == bookmarkFillImage || button.tag == 10 {
                        
//                        DataStore.shared.bookmarkArray = DataStore.shared.bookmarkArray.filter { $0 != [bookmark] }
//
//                        updateBookmarkList(bookmark)
                        
                        //NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
//                        print("북마크 해제 DataStore.shared.bookmarkArray.count: \(DataStore.shared.bookmarkArray.count)")
                        button.setImage(bookmarkImage, for: .normal)
                        print("")
                    } else {
//                        bookmarkArray.append(bookmark)
//                        DataStore.shared.bookmarkArray.append(bookmarkArray)
//
//                        uploadBookmarkList(bookmark)

                        //NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
//                        bookmarkArray = []
//                        print("북마크 설정 DataStore.shared.bookmarkArray.count: \(DataStore.shared.bookmarkArray.count)")
                        button.setImage(bookmarkFillImage, for: .normal)
                        shareURLToSafari(url: URL(string: urlText)!)
                        print("")
                    }
                    
                }
            }
        }
    }
    
    //MARK: - 컬렉션 뷰 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        if collectionView.tag == 1 {
            
            let cellWidth = collectionView.frame.height
            let cellHeight = collectionView.frame.height + 5
            
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            // trendingCollectionView의 각 셀 크기 설정
            if DataStore.shared.loadedNewsSearchArray.count != 0 { // 데이터가 있는 경우,
                let cellWidth = collectionView.bounds.width - 40
                //let cellWidth = collectionView.bounds.width * 2.0
                let cellHeight = collectionView.bounds.height
                return CGSize(width: cellWidth , height: cellHeight)
            } else { // 데이터가 없는 경우
                let cellWidth = collectionView.bounds.width
                let cellHeight = collectionView.bounds.height
                return CGSize(width: cellWidth , height: cellHeight)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // 아이템 사이의 간격
        if collectionView.tag == 1 {
            return -20
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 아이템의 개수
        if collectionView.tag == 1 {
            
            let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: keywordCollectionView.bounds.size.width, height: keywordCollectionView.bounds.size.height))
            placeholderLabel.text = "키워드를 추가해보세요"
            placeholderLabel.textAlignment = .center
            placeholderLabel.textColor = .gray
            
            print("loadingIndicator.isAnimating: \(loadingIndicator.isAnimating)")
            
            if UserDefaults.standard.string(forKey: "uid") != nil { // 유저가 로그인한 상태
                if DataStore.shared.userInputKeyword.isEmpty {
                    
                    if loadingIndicator.isAnimating {
                        DispatchQueue.main.async {
                            self.keywordCollectionView.backgroundView = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.keywordCollectionView.backgroundView = placeholderLabel
                        }
                    }
                    
                    return 1 // 데이터가 없으면 Placeholder를 위한 셀을 1개 반환
                    
                } else {
                    keywordCollectionView.backgroundView = nil
                    return DataStore.shared.userInputKeyword.count + 1
                    // 데이터가 있으면 실제 데이터 개수 반환
                    
                }
            } else { // 신규 유저이거나 로그인하지 않은 상태
                if DataStore.shared.userInputKeyword.isEmpty {
                    
                    if loadingIndicator.isAnimating {
                        DispatchQueue.main.async {
                            self.keywordCollectionView.backgroundView = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.keywordCollectionView.backgroundView = placeholderLabel
                        }
                    }
                    
                    return 1 // 데이터가 없으면 Placeholder를 위한 셀을 1개 반환
                    
                } else {
                    keywordCollectionView.backgroundView = nil
                    return DataStore.shared.userInputKeyword.count + 1
                    // 데이터가 있으면 실제 데이터 개수 반환
                }
            }
        } else { // collectionView.tag == 2
            
            if DataStore.shared.loadedNewsSearchArray.count != 0 {
                return DataStore.shared.loadedNewsSearchArray.count + 1
                // 데이터가 있으면 실제 데이터 개수 반환
            } else {
                return 1 // placeholder 1개 + 광고 셀 1개
            }
        }
    }
    
    //    func numberOfRows(in collectionView: UICollectionView) -> Int {
    //        if collectionView.tag == 1 {
    //            return 1
    //        } else {
    //            return 8
    //        }
    //    }
    //
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return 1
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 아이템들 사이의 가로 간격
        if collectionView.tag == 1 {
            return 0
        } else {
            return 10
        }
    }
    
}
extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    func alignTextVerticallyInContainer() {
        var topCorrct = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrct = topCorrct < 0.0 ? 0.0 : topCorrct;
        self.contentInset.top = topCorrct
    }
}


extension AcrhiveViewController {
    
    func loadUserKeyword(completion: @escaping () -> Void) {
        print("loadUserKeyword 진입")
        // keywordList
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            db.collection("KeywordList").document(userUid).getDocument { documentSnapshot, error in
                if let error = error { // 나의 유저정보 로드
                    print("There was NO saving data to firestore, \(error)")
                } else {
                    if let document = documentSnapshot {
                        if let data = document.data() {
                            let rawKeywordList = data["KeywordList"] as! [String]
                            UserDefaults.standard.set(rawKeywordList, forKey: "KeywordList")
                            
                            let keywordList = UserDefaults.standard.array(forKey: "KeywordList") as! [String]
                            DataStore.shared.userInputKeyword = keywordList
                            print("keywordList: \(keywordList)")
                            //print("DataStore.shared.userInputKeyword: \(DataStore.shared.userInputKeyword)")
                            DispatchQueue.main.async {
                                //self.keywordCollectionView.reloadData()
                                print("loadUserKeyword 완료")
                                self.keywordCollectionView.performBatchUpdates({
                                    let indexSet = IndexSet(integersIn: 0...0)
                                    self.keywordCollectionView.reloadSections(indexSet)
                                }, completion: nil)
                            }
                            
                        }
                    } else {
                        print("no keywordList")
                    }
                }
                completion()
            }
            
        }
        
    }
}
