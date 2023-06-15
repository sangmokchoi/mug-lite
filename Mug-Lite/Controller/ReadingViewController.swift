//
//  ReadingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit
import OHCubeView

class ReadingViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 비디오 데이터 읽어오기
    let loadedNewsSearchArray = DataStore.shared.loadedNewsSearchArray // 뉴스 데이터 읽어오기
    
    var query : String? // '키워드 추가' 컬렉션 뷰에서 가져온 쿼리명을 저장
    let refreshControl = UIRefreshControl()
    var offset = 0
    
    @IBOutlet weak var cubeView: OHCubeView!
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: view.bounds)
        return containerView
    }()
    
//    lazy var refreshButton: UIButton = {
//        let refreshButton = UIButton(type: .system)
//        refreshButton.backgroundColor = .clear
//        refreshButton.setTitle("새로고침", for: .normal)
//        refreshButton.setImage(UIImage(named: "arrow.clockwise"), for: .normal)
//        refreshButton.setTitleColor(.black, for: .normal)
//
//        return refreshButton
//    }()
    
    // Notification을 처리하는 함수
    @objc func handleNotification(notification: Notification) {
        
        //cubeView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        if let userInfo = notification.userInfo,
           let direction = userInfo["direction"] as? UISwipeGestureRecognizer.Direction {
            if direction == .left {
                // 왼쪽 스와이프 동작 처리
                print("Left swipe333")

                let getChildViewsCount = cubeView.getChildViewsCount()
                //cubeView 내 스택 뷰의 서브뷰 개수
                if getChildViewsCount < DataStore.shared.totalSearch.count {
                    let firstArray = DataStore.shared.totalSearch[getChildViewsCount]
                    imageViewSet(firstArray: firstArray)
                } else {
                    // 배열의 인덱스 범위를 초과한 경우에 대한 처리를 여기에 작성
                    // 예: 마지막 요소를 사용하거나, 다른 인덱스를 선택하는 등의 방법으로 오류를 방지
                    print("index out of range")
                }
            } else if direction == .right {
                // 오른쪽 스와이프 동작 처리

                print("Right swipe333")
                // 추가적인 처리를 위한 코드 작성
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("MyNotification"), object: nil)
        DataStore.shared.merge()
        //initRefresh()
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
        
        let firstArray2 = DataStore.shared.totalSearch[2]
        imageViewSet(firstArray: firstArray2)
        //print("firstArray0: \(firstArray0)")

        let firstArray3 = DataStore.shared.totalSearch[3]
        imageViewSet(firstArray: firstArray3)
        print("뷰의 개수: \(viewCount)")
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let firstArray0 = DataStore.shared.totalSearch[0]
        imageViewSet(firstArray: firstArray0)
        //print("firstArray0: \(firstArray0)")

        let firstArray1 = DataStore.shared.totalSearch[1]
        imageViewSet(firstArray: firstArray1)
        
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
    func imageViewSet(firstArray : [Any]) { //APIData.webNewsSearch
        
        print("imageViewSet 진입")
        let totalSearch = DataStore.shared.totalSearch

        if let newsArray = firstArray as? [APIData.webNewsSearch] {
            print("APIData.webNewsSearch 임")
            
            // totalSearch 배열의 첫 번째 요소가 webNewsSearch 타입의 배열일 경우
            var imageUrl = newsArray[0].image.contentUrl
            var imageWidth = newsArray[0].image.width
            var imageHeight = newsArray[0].image.height
            var inputDate = newsArray[0].datePublished
            var context = newsArray[0].name
            var distributor = newsArray[0].provider.name
            var contentUrl = newsArray[0].webSearchUrl

            downloadImage(with: imageUrl, completion: { image in
                
                let noiseReducedImage = self.Image_ReduceNoise(image: image ?? UIImage(named: "AppIcon")!)
                let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
                
                if let image = sharpnessEnhancedImage {
                    // 다운로드한 이미지를 사용하여 UI 업데이트
                    // UI 업데이트는 메인 스레드에서 처리
                    DispatchQueue.main.async {
                        
                        let newView = UIView(frame: self.view.bounds)
                        
                        let backgroundImageView = UIImageView(image: image)
                        backgroundImageView.contentMode = .scaleAspectFill
                        //backgroundImageView.clipsToBounds = true
                        
                        let blurEffect = UIBlurEffect(style: .dark)
                        let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
                        
                        backgroundImageView.frame = self.view.bounds
                        viewBlurEffect.frame = backgroundImageView.frame
                        
                        let mainImage = UIImageView(image: image)
                        mainImage.frame = newView.bounds
                        mainImage.contentMode = .scaleAspectFit
                        
                        for subview in backgroundImageView.subviews {
                            subview.removeFromSuperview()
                        }
                        
                        let label = UILabel(frame: self.view.bounds)
                        label.text = context
                        
                        let webViewButton = UIButton()
                        webViewButton.frame = CGRect(x: Int(self.view.bounds.minX), y: Int(self.view.bounds.midY)/4, width: 250, height: 30)
                        webViewButton.backgroundColor = .white
                        webViewButton.layer.masksToBounds = true
                        webViewButton.layer.cornerRadius = 5
                        
                        webViewButton.setTitle("\(contentUrl)", for: .normal)
                        webViewButton.setTitleColor(.black, for: .normal)
                        
                        // Add an event
                        webViewButton.addTarget(self, action: #selector(self.webViewClickButton(_:)), for: .touchUpInside)
                        
                        let refreshButton = UIButton(type: .system)
                        refreshButton.backgroundColor = .clear
                        
                        //refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
                        if let refreshImage = UIImage(systemName: "arrow.clockwise")?.withRenderingMode(.alwaysTemplate) {
                            refreshButton.setImage(refreshImage, for: .normal)
                            refreshButton.tintColor = UIColor(named: "AccentTintColor")
                        }
                        
                        refreshButton.frame = CGRect(x: self.view.bounds.maxX - 100, y: self.view.bounds.minY + 40, width: 80, height: 40)
                        refreshButton.addTarget(self, action: #selector(self.loadData(_:)), for: .touchUpInside)

                        newView.addSubview(backgroundImageView)
                        newView.addSubview(viewBlurEffect)
                        newView.addSubview(mainImage)
                        newView.addSubview(label)
                        newView.addSubview(webViewButton)
                        newView.addSubview(refreshButton)
                        
                        //print("newView 생성")
                        self.cubeView.addChildView(newView)
                        //self.cubeView.contentOffset = .zero

                        //print("self.cubeView: \(self.cubeView)")
                        //self.cubeView.printChildViews()
                        
                        //self.view.bringSubviewToFront(self.cubeView)
                        
                        // containerView에 이미지가 추가됨
                        //self.view.addSubview(self.containerView)
                        //self.view.sendSubviewToBack(self.containerView)
                        
                        //self.cubeView.addSubview(self.containerView)// 배열 넣기
                        
                        //cell.contentTextView.contentOffset = .zero
                        
                    }
                }
            })
            
        } else if let videoArray = firstArray as? [APIData.webVideoSearch] {
            print("APIData.webVideoSearch 임")
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
                    // 다운로드한 이미지를 사용하여 UI 업데이트
                    // UI 업데이트는 메인 스레드에서 처리
                    DispatchQueue.main.async {
                        
                        let newView = UIView(frame: self.view.bounds)
                        
                        let backgroundImageView = UIImageView(image: image)
                        backgroundImageView.contentMode = .scaleAspectFill
                        //backgroundImageView.clipsToBounds = true
                        
                        let blurEffect = UIBlurEffect(style: .dark)
                        let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
                        
                        backgroundImageView.frame = self.view.bounds
                        viewBlurEffect.frame = backgroundImageView.frame
                        
                        let mainImage = UIImageView(image: image)
                        mainImage.frame = newView.bounds
                        mainImage.contentMode = .scaleAspectFit
                        
                        for subview in backgroundImageView.subviews {
                            subview.removeFromSuperview()
                        }
                        
                        let label = UILabel(frame: self.view.bounds)
                        label.text = context
                        
                        let webViewButton = UIButton()
                        webViewButton.frame = CGRect(x: Int(self.view.bounds.minX), y: Int(self.view.bounds.midY)/4, width: 250, height: 30)
                        webViewButton.backgroundColor = .white
                        webViewButton.layer.masksToBounds = true
                        webViewButton.layer.cornerRadius = 5
                        
                        webViewButton.setTitle("\(contentUrl)", for: .normal)
                        webViewButton.setTitleColor(.black, for: .normal)
                        
                        // Add an event
                        webViewButton.addTarget(self, action: #selector(self.webViewClickButton(_:)), for: .touchUpInside)
                        
                        let refreshButton = UIButton(type: .system)
                        refreshButton.backgroundColor = .clear
                        
                        //refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
                        if let refreshImage = UIImage(systemName: "arrow.clockwise")?.withRenderingMode(.alwaysTemplate) {
                            refreshButton.setImage(refreshImage, for: .normal)
                            refreshButton.tintColor = UIColor(named: "AccentTintColor")
                        }
                        
                        refreshButton.frame = CGRect(x: self.view.bounds.maxX - 100, y: self.view.bounds.minY + 40, width: 80, height: 40)
                        refreshButton.addTarget(self, action: #selector(self.loadData(_:)), for: .touchUpInside)
                        
                        newView.addSubview(backgroundImageView)
                        newView.addSubview(viewBlurEffect)
                        newView.addSubview(mainImage)
                        newView.addSubview(label)
                        newView.addSubview(webViewButton)
                        newView.addSubview(refreshButton)
                        
                        //print("newView 생성")
                        self.cubeView.addChildView(newView)
                        //self.cubeView.contentOffset = .zero

                        //print("self.cubeView: \(self.cubeView)")
                        //self.cubeView.printChildViews()
                        //self.view.bringSubviewToFront(self.cubeView)
                        
                        // containerView에 이미지가 추가됨
                        //self.view.addSubview(self.containerView)
                        //self.view.sendSubviewToBack(self.containerView)
                        
                        //self.cubeView.addSubview(self.containerView)// 배열 넣기
                        
                    }
                }
            })
        }
        print("이도 저도 아닌 상태...")

        
        
    }
    
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
    
    @objc internal func webViewClickButton(_ sender: Any) {
            if let button = sender as? UIButton {
                print("button.currentTitle: \(button.currentTitle!)")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                
                nextVC.query = self.query
                nextVC.url = button.currentTitle
                
                // UINavigationController를 이용하여 전체 화면으로 표시
                let navigationController = UINavigationController(rootViewController: nextVC)
                //navigationController.modalPresentationStyle = .fullScreen
                
                // 현재의 뷰 컨트롤러에서 전환 실행
                present(navigationController, animated: true, completion: nil)
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

