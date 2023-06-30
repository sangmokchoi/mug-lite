//
//  ReadingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit
import OHCubeView
import SafariServices

class ReadingViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 비디오 데이터 읽어오기
    let loadedNewsSearchArray = DataStore.shared.loadedNewsSearchArray // 뉴스 데이터 읽어오기
    
    var query : String? // '키워드 추가' 컬렉션 뷰에서 가져온 쿼리명을 저장
    let refreshControl = UIRefreshControl()
    var offset = 0
    var tapCount = 0
    var tmpUrl = ""
    
    var bookmarkArray : [APIData.Bookmarked] = []
    
    var bookmarkContext: String = ""
    var bookmarkContentUrl: String = ""
    var bookmarkDate: String = ""
    var bookmarkDistributor: String = ""
    
    @IBOutlet weak var cubeView: OHCubeView!
    
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: view.bounds)
        return containerView
    }()
    
    @objc func stopLoadingView() {
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
    }
    
//    lazy var refreshButton: UIButton = {
//        let refreshButton = UIButton(type: .system)
//        refreshButton.backgroundColor = .clear
//        refreshButton.setTitle("새로고침", for: .normal)
//        refreshButton.setImage(UIImage(named: "arrow.clockwise"), for: .normal)
//        refreshButton.setTitleColor(.black, for: .normal)
//
//        return refreshButton
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReadingVC query: \(query!)")
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("MyNotification"), object: nil)
        
        // news 콜과 video 콜이 모두 완료되고 나면 머지를 해야 함.
        NotificationCenter.default.addObserver(self, selector: #selector(mergeStart), name: NSNotification.Name(rawValue: "mergeIsReadyFromNews"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mergeStart), name: NSNotification.Name(rawValue: "mergeIsReadyFromVideo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)

        //initRefresh()
    }
    
    @objc func mergeStart() {
        print("mergeStart 진입")
        if !DataStore.shared.loadedKeywordNewsArray.isEmpty  { //&& !DataStore.shared.loadedVideoSearchArray.isEmpty
            DataStore.shared.merge()
            
            let firstArray0 = DataStore.shared.totalSearch[0]
            imageViewSet(firstArray: firstArray0)
            //print("firstArray0: \(firstArray0)")

            let firstArray1 = DataStore.shared.totalSearch[1]
            imageViewSet(firstArray: firstArray1)
//            print("mergeStart DataStore.shared.merge()진입")
        } else { // 값이 비었으므로 유저를 뒤로 보내야함
            let alertController = UIAlertController(title: "불러온 콘텐츠가 없습니다", message: "이전 화면으로 돌아갑니다", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action1)
            self.present(alertController, animated: true)
        }
        print("if !DataStore.shared.loadedKeywordNewsArray.isEmpty && !DataStore.shared.loadedVideoSearchArray.isEmpty 빠져나감")

//        DispatchQueue.main.async {
//            self.cubeView.reloadInputViews()
//            print("mergeStart DataStore.shared.merge()진입")
//        }
    }
    
    // 스와이프 Notification을 처리하는 함수
    @objc func handleNotification(notification: Notification) {
        
        let getChildViewsCount = cubeView.getChildViewsCount() //cubeView 내 스택 뷰의 서브뷰 개수
        print("getChildViewsCount: \(getChildViewsCount)")
        //cubeView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        if let userInfo = notification.userInfo,
           let direction = userInfo["direction"] as? UISwipeGestureRecognizer.Direction {
            
            if direction == .left {
                // 왼쪽 스와이프 동작 처리
                print("Left swipe333")
                print("DataStore.shared.totalSearch.count: \(DataStore.shared.totalSearch.count)")

                if getChildViewsCount < DataStore.shared.totalSearch.count {
                    let firstArray = DataStore.shared.totalSearch[getChildViewsCount]
                    imageViewSet(firstArray: firstArray)
                    tapCount += 1
                    print("cubeView.getChildViewsCount():\(cubeView.getChildViewsCount())")
                } else {
                    // 배열의 인덱스 범위를 초과한 경우에 대한 처리를 여기에 작성
                    // 예: 마지막 요소를 사용하거나, 다른 인덱스를 선택하는 등의 방법으로 오류를 방지
                    print("index out of range")
                    //let firstArray = DataStore.shared.totalSearch[getChildViewsCount-1]
                    //imageViewSet(firstArray: firstArray)
                    print("cubeView.getChildViewsCount():\(cubeView.getChildViewsCount())")
                }
            } else if direction == .right {
                // 오른쪽 스와이프 동작 처리
                print("Right swipe333")
                if tapCount == 0 {
                    print("cubeView.getChildViewsCount():\(cubeView.getChildViewsCount())")
                } else {
                    tapCount -= 1
                    print("cubeView.getChildViewsCount():\(cubeView.getChildViewsCount())")
                }
            }
            print("tapCount : \(tapCount)")
        }
    }
    
    func initRefresh() {
        refreshControl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        
        refreshControl.backgroundColor = .black
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "사진을 불러오는 중입니다")
        
        cubeView.refreshControl = refreshControl
    }
    
    func totalSearchArray(completion: @escaping () -> Void) {
        // 데이터 로딩 작업 수행
        if DataStore.shared.totalSearch.isEmpty {
            // 데이터가 없는 경우에 대한 처리
            print("No data found in DataStore.shared.totalSearch")
            completion()
            return
        }

        // 데이터 로딩이 완료되면 completion closure 호출
        completion()
    }
    
    @objc internal func loadData(_ sender: Any) {
        // 데이터 로딩 시작 시 refreshControl 활성화
        //refreshControl.beginRefreshing()
        print("loadData 진입")
        var viewCount = self.cubeView.getChildViewsCount()
        print("뷰의 개수: \(viewCount)")
        
//        let firstArray2 = DataStore.shared.totalSearch[2]
//        imageViewSet(firstArray: firstArray2)
//        //print("firstArray0: \(firstArray0)")
//
//        let firstArray3 = DataStore.shared.totalSearch[3]
//        imageViewSet(firstArray: firstArray3)
//        print("뷰의 개수: \(viewCount)")
        
//        totalSearchArray { [weak self] in
//            // 데이터 로딩이 완료되면 호출되는 closure
//            let totalSearchCount = DataStore.shared.totalSearch.count
//            print("totalSearchCount: \(totalSearchCount)")
//
//            for i in 0...totalSearchCount-1 { //totalSearchCount-1로 설정하니 그 개수가 매우 많아짐. 동적으로 어레이의 값들을 카운트해서 적용해야함
//                DispatchQueue.main.async {
//                    let firstArray = DataStore.shared.totalSearch[i]
//                    print("DispatchQueue.main.async firstArray 진입")
//                    self!.imageViewSet(firstArray: firstArray)
//                }
//            }
//            let desiredIndex = totalSearchCount-1 // 이동하고자 하는 뷰의 인덱스
//            print("desiredIndex: \(desiredIndex)")
//
//            self!.cubeView.scrollToViewAtIndex(viewCount, animated: true)
//        }
        // 데이터 로딩 완료 후 refreshControl 비활성화
        //self.refreshControl.endRefreshing()
        print("endRefreshing 진입")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //DataStore.shared.totalSearch = []
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 모든 제스처를 동시에 인식할 수 있도록 설정
        return true
        }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 다른 제스처가 동작하는 동안에는 스와이프 제스처 인식을 계속하도록 설정
        return true
    }

}

extension ReadingViewController {
    //DataStore.shared.totalSearch
    func imageViewSet(firstArray : [Any]) { //APIData.webNewsSearch

        if let newsArray = firstArray as? [APIData.webNewsSearch] {
            // totalSearch 배열의 첫 번째 요소가 webNewsSearch 타입의 배열일 경우
            var imageUrl = newsArray[0].image.contentUrl
            var imageWidth = newsArray[0].image.width
            var imageHeight = newsArray[0].image.height
            var inputDate = newsArray[0].datePublished
            var context = newsArray[0].name
            var distributor = newsArray[0].provider.name
            var contentUrl = newsArray[0].webSearchUrl
            print("imageViewSet contentUrl : \(contentUrl)")
            downloadImage(with: imageUrl, completion: { image in
                let noiseReducedImage = self.Image_ReduceNoise(image: image ?? UIImage(named: "AppIcon")!)
                let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
                
                if let image = sharpnessEnhancedImage {
                    self.updateUI(image: image, context: context, contentUrl: contentUrl, date: inputDate, distributor: distributor, imageWidth: imageWidth, imageHeight: imageHeight)
                }
            })
            
        } else if let videoArray = firstArray as? [APIData.webVideoSearch] {
            // totalSearch 배열의 첫 번째 요소가 webVideoSearch 타입의 배열일 경우
            // 데이터를 가져오고 사용하는 코드 작성
            var imageUrl = videoArray[0].thumbnailUrl
            var imageWidth = videoArray[0].width
            var imageHeight = videoArray[0].height
            var inputDate = videoArray[0].datePublished
            var context = videoArray[0].name
            var distributor = videoArray[0].publisher.name
            var contentUrl = videoArray[0].contentUrl
            
            downloadImage(with: imageUrl, completion: { image in
                
                let noiseReducedImage = self.Image_ReduceNoise(image: image ?? UIImage(named: "AppIcon")!)
                let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
                
                if let image = sharpnessEnhancedImage {
                    self.updateUI(image: image, context: context, contentUrl: contentUrl, date: inputDate, distributor: distributor, imageWidth: imageWidth, imageHeight: imageHeight)
                }
            })
        }
        print("이도 저도 아닌 상태...")

    }
    
    func updateUI(image: UIImage?, context: String, contentUrl: String, date: String, distributor: String, imageWidth: Int, imageHeight: Int) { // 다운로드한 이미지를 사용하여 UI 업데이트
        
        self.bookmarkContext = ""
        self.bookmarkContentUrl = ""
        self.bookmarkDate = ""
        self.bookmarkDistributor = ""
        
        // UI 업데이트는 메인 스레드에서 처리
        DispatchQueue.main.async {
            let newView = UIView(frame: self.view.bounds)
            
            // 하단 그라디언트 추가
            let newView1 = UIView(frame: self.view.bounds)
            newView1.setGradient(color1: .clear, color2: .black, location1: 0.0, location2: 0.6, location3: 1.0, startPoint1: 0.5, startPoint2: 0.5, endPoint1: 0.5, endPoint2: 1.0)
            
            // 상단 그라디언트 추가
            let newView2 = UIView(frame: self.view.bounds)
            newView2.setGradient(color1: .black, color2: .clear, location1: 0.0, location2: 0.5, location3: 1.0, startPoint1: 0.5, startPoint2: 0.0, endPoint1: 0.5, endPoint2: 0.5)
            
            let backgroundImageView = UIImageView(image: image)
            backgroundImageView.contentMode = .scaleAspectFill
            //backgroundImageView.clipsToBounds = true
            
            let blurEffect = UIBlurEffect(style: .dark)
            let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
            
            backgroundImageView.frame = self.view.bounds
            viewBlurEffect.frame = backgroundImageView.frame
            
            let mainImage = UIImageView(image: image)
            mainImage.frame = newView.bounds
            if imageHeight == 0 || imageWidth == 0 {
                mainImage.contentMode = .scaleAspectFit
                print("image입니다 한 번 살펴볼까요: \(image)")
                if image != UIImage(named: "AppIcon") {
                    // 1. 뷰의 프레임 크기를 디바이스 화면 크기의 1/4로 설정
                    let screenSize = UIScreen.main.bounds.size
                    let quarterSize = CGSize(width: screenSize.width / 4, height: screenSize.height / 4)

                    // 2. 가로 및 세로 비율 유지를 위해 contentMode 설정
                    mainImage.frame.size = quarterSize
                    mainImage.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                } else { // 앱 아이콘

                }
            } else {
                mainImage.contentMode = .scaleAspectFit
            }
            
            for subview in backgroundImageView.subviews {
                subview.removeFromSuperview()
            }
            
            let xButton = UIButton(type: .system)
            xButton.frame = CGRect(x: 5, y: 20, width: 30, height: 40)
            xButton.backgroundColor = .clear
            
            if let xmarkImage = UIImage(systemName: "xmark.circle")?.withTintColor(.white, renderingMode: .alwaysTemplate) {
                xButton.setImage(xmarkImage, for: .normal)
                xButton.tintColor = .white
                
                xButton.addTarget(self, action: #selector(self.goBack(_:)), for: .touchUpInside)
            }
            
            let keywordLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 300, height: 30))
            keywordLabel.text = "#\(self.query!)"// self.query
            keywordLabel.font = .systemFont(ofSize: 24, weight: .bold)
            keywordLabel.textColor = .white
            keywordLabel.textAlignment = .left
            //keywordLabel.center.x = self.view.center.x
            //keywordLabel.backgroundColor = .white
            //self.tmpUrl = contentUrl
            //if self.tmpUrl == "" {

            //}
            keywordLabel.layer.borderColor = UIColor.white.cgColor
            keywordLabel.layer.cornerRadius = 5
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 40, width: 300, height: 100))
            titleLabel.text = context
            titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 3
            titleLabel.frame.origin.y =
            self.view.bounds.maxY - 25 - titleLabel.frame.height
            titleLabel.textAlignment = .center
            //titleLabel.center = self.view.center
            titleLabel.center.x = self.view.center.x
            titleLabel.tag = 1
            
            let distributorLabel = UILabel(frame: CGRect(x: 10, y: 45, width: 150, height: 20))
            distributorLabel.text = distributor
            distributorLabel.font = .systemFont(ofSize: 10)
            distributorLabel.tag = 2
            distributorLabel.textColor = .white
            
            let dateLabel = UILabel(frame: CGRect(x: 10, y: 55, width: 150, height: 20))
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            if let newDate = inputFormatter.date(from: date) {
                let outputDatePublished = outputFormatter.string(from: newDate)
                dateLabel.text = outputDatePublished
            } else {
                print("Invalid input string")
            }
            dateLabel.font = .systemFont(ofSize: 10)
            dateLabel.tag = 3
            dateLabel.textColor = .white
            
            let webViewButton = UIButton(frame: CGRect(
                x: Int(self.view.bounds.minX)+30,
                y: Int(self.view.bounds.maxY)/2,
                width: 135, height: 35))
            webViewButton.center.x = self.view.center.x
            webViewButton.frame.origin.y =
            self.view.bounds.maxY - 125 - webViewButton.frame.height
            
            webViewButton.backgroundColor = .white
            webViewButton.layer.masksToBounds = true
            webViewButton.layer.cornerRadius = 5
            webViewButton.titleLabel?.lineBreakMode = .byTruncatingTail
            
            webViewButton.setTitle("\(contentUrl)", for: .normal) // contentUrl
            webViewButton.setTitleColor(.white, for: .normal)
            webViewButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            webViewButton.tag = 1
            
            // Add an event
            webViewButton.addTarget(self, action: #selector(self.webViewClickButton(_:)), for: .touchUpInside)
            
            let directlyGoLabel = UILabel(frame: webViewButton.frame)
            directlyGoLabel.text = "바로가기"
            directlyGoLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            directlyGoLabel.textAlignment = .center
            directlyGoLabel.backgroundColor = .clear
            directlyGoLabel.textColor = .black
            directlyGoLabel.tag = 5
            
            let refreshButton = UIButton(type: .system)
            refreshButton.backgroundColor = .clear
            refreshButton.tag = 2
            
            let bookmarkButton = UIButton(type: .system)
            bookmarkButton.backgroundColor = .clear
            bookmarkButton.tag = 3
            
            //refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            if let refreshImage = UIImage(systemName: "arrow.clockwise")?.withTintColor(UIColor(named: "AccentTintColor")!, renderingMode: .alwaysTemplate) {
                refreshButton.setImage(refreshImage, for: .normal)
                refreshButton.tintColor = .white
            }
            
            if let bookmarkImage = UIImage(systemName: "bookmark")?.withTintColor(.white, renderingMode: .alwaysTemplate), let bookmarkFillImage = UIImage(systemName: "bookmark.fill")?.withTintColor(.white, renderingMode: .alwaysTemplate) {
                
                // 여기에서 url 여부에 따라 버튼의 이미지를 결정해야 함
                if self.bookmarkUrlCheck(contentUrl) == true { // true 이므로 저장된 북마크가 있음
                    print("true 이므로 저장된 북마크가 있음")
                    bookmarkButton.setImage(bookmarkFillImage, for: .normal)
                    bookmarkButton.tintColor = .white
                    bookmarkButton.tag = 10
                } else { // false 이므로 저장된 북마크가 없음
                    print("false 이므로 저장된 북마크가 없음")
                    bookmarkButton.setImage(bookmarkImage, for: .normal)
                    bookmarkButton.tintColor = .white
                    bookmarkButton.tag = 11
                }
            }

            refreshButton.frame = CGRect(
                x: Int(self.view.bounds.maxX) - 110,
                y: 20,
                width: 80, height: 40)
            refreshButton.addTarget(self, action: #selector(self.loadData(_:)), for: .touchUpInside)
            
            bookmarkButton.frame = CGRect(
                x: Int(self.view.bounds.maxX) - 70,
                y: 20,
                width: 80, height: 40)
            bookmarkButton.addTarget(self, action: #selector(self.bookmarkButtonPressed(_:)), for: .touchUpInside)
            
            newView.addSubview(backgroundImageView)
            newView.addSubview(viewBlurEffect)
            newView.addSubview(mainImage)
            newView.addSubview(newView1)
            newView.bringSubviewToFront(newView1)
            newView.addSubview(newView2)
            newView.bringSubviewToFront(newView2)
            //newView.addSubview(xButton)
            newView.addSubview(keywordLabel)
            newView.addSubview(titleLabel)
            newView.addSubview(distributorLabel)
            newView.addSubview(dateLabel)
            newView.addSubview(webViewButton)
            newView.addSubview(directlyGoLabel)
            //newView.addSubview(refreshButton)
            newView.addSubview(bookmarkButton)
            
            var getChildViewsCount = self.cubeView.getChildViewsCount()
            //print("getChildViewsCount: \(getChildViewsCount)")
            newView.tag = getChildViewsCount

            //self.cubeView.contentOffset = .zero
            self.cubeView.addChildView(newView)
            
            if getChildViewsCount == DataStore.shared.totalSearch.count-1 {
                newView.addSubview(refreshButton)
                print("newView.addSubview(refreshButton)")
            } else {
                print("getChildViewsCount < DataStore.shared.totalSearch.count")
                
            }
    
            }
    }
    
    @objc internal func goBack(_ sender: Any) {
        if let navigationController = navigationController {
            print("navigationController")
            //navigationController.popViewController(animated: true)
            navigationController.dismiss(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc internal func webViewClickButton(_ sender: Any) {
        if let button = sender as? UIButton {
            print("button.currentTitle: \(button.currentTitle!)")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            
            nextVC.query = self.query
            
//            if let nextVCUrl = button.currentTitle {
//
//                if nextVCUrl.contains("http:") {
//                    let strippedName0 = nextVCUrl.replacingOccurrences(of: "http:", with: "https:")
//                    nextVC.url = strippedName0
//                } else {
//                    nextVC.url = button.currentTitle
//                }
//            }
            nextVC.url = button.currentTitle
            
            
            
            // UINavigationController를 이용하여 전체 화면으로 표시
            //let navigationController = UINavigationController(rootViewController: nextVC)
            //navigationController.modalPresentationStyle = .fullScreen
            
            // 현재의 뷰 컨트롤러에서 전환 실행
            //present(navigationController, animated: true, completion: nil)
            
            let URL = URL(string: button.currentTitle!)!
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: URL, configuration: config)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet

            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc internal func bookmarkButtonPressed(_ sender: Any) {
        
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
                            case 1: // title
                                titleText = label.text ?? ""
                            case 2: // distributor
                                distributorText = label.text ?? ""
                            case 3: // date
                                dateText = label.text ?? ""
                            default:
                                break
                        }
                    } else if let urlButton = subview as? UIButton {
                        switch urlButton.tag {
                            case 1: // webViewButton
                                urlText = urlButton.titleLabel?.text ?? ""
                                //print("urlText: \(urlText)")
                            case 2: // refreshButton
                                print("")
                            case 3: // bookmarkButton
                                print("")
                            default:
                                break
                        }
                        
                    }
                }
                // APIData.Bookmarked에 값을 할당하여 bookmarkArray에 추가
                let bookmark = APIData.Bookmarked(
                    query: self.query ?? "",
                    url: urlText,
                    name: titleText,
                    datePublished: dateText,
                    distributor: distributorText
                )
                
                if button.image(for: .normal) == bookmarkFillImage || button.tag == 10 {
                    
                    DataStore.shared.bookmarkArray = DataStore.shared.bookmarkArray.filter { $0 != [bookmark] }
                    uploadBookmarkList(bookmark)
                    
                    NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
                    print("북마크 해제 DataStore.shared.bookmarkArray.count: \(DataStore.shared.bookmarkArray.count)")
                    button.setImage(bookmarkImage, for: .normal)
                    print("")
                } else {
                    bookmarkArray.append(bookmark)
                    DataStore.shared.bookmarkArray.append(bookmarkArray)

                    uploadBookmarkList(bookmark)

                    NotificationCenter.default.post(name: Notification.Name("updateBookmarkTableView"), object: nil)
                    bookmarkArray = []
                    print("북마크 설정 DataStore.shared.bookmarkArray.count: \(DataStore.shared.bookmarkArray.count)")
                    button.setImage(bookmarkFillImage, for: .normal)
                    print("")
                }
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ArchiveToReading" {
//            let nextVC = segue.destination as? WebViewController
//
//            if let index = sender as? Int {
//
//            }
//        }
//    }
}

extension ReadingViewController {
    
    func bookmarkUrlCheck(_ url: String) -> Bool {
        // 1.url이 북마크에 저장된 적이 있는지 확인
        // ( url을 DataStore.shared.bookmarkArray에 조회해서 DataStore.shared.totalSearch의 webSearchUrl에 존재하는지 확인)
        var isStringUrl = false

        for i in 0..<DataStore.shared.bookmarkArray.count {
            let urlCheck = DataStore.shared.bookmarkArray[i][0].url
            
            if url == urlCheck { // 저장된 북마크 있음
                isStringUrl = true
                print("저장된 북마크 있음")

                return isStringUrl
            } else { // 저장된 북마크 없음
                isStringUrl = false
                print("저장된 북마크 없음")
            }
        }

        return isStringUrl
    }
}

extension UIViewController {
    func downloadImage(with imageUrl: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Error: No image data.")
                completion(nil)
                return
            }
            // 다운로드한 데이터를 UIImage로 변환
            guard let image = UIImage(data: data) else {
                print("Error: Cannot convert data to image.")
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
    func uploadBookmarkList(_ bookmarkList: APIData.Bookmarked) {
        print("uploadBookmarkList 진입")
        
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
                        // 문서가 존재하는 경우, 기존 데이터에 새로운 데이터를 추가하여 업데이트
                        var existingData = document.data()?["BookmarkList"] as? [[String: Any]] ?? []
                        existingData.append(jsonDict)
                        documentRef.updateData(["BookmarkList": existingData]) { error in
                            if let error = error {
                                print("Error updating data in Firestore: \(error)")
                            } else {
                                print("Data updated successfully in Firestore")
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
