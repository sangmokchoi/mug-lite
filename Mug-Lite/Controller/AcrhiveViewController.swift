//
//  AcrhiveViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//
import Foundation
import UIKit

class AcrhiveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var trendingNewsLabel: UILabel!
    @IBOutlet weak var trendingNewsRefreshButton: UIButton!
    
    let mkt = "ko-KR"
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
    var count = 0
    var totalEstimatedResults = 0
    let refreshControl = UIRefreshControl()
    
    let mainVC = MainViewController()
    
    var dataStore = DataStore.shared
    
    let cellSpacingHeight : CGFloat = 1
    
    var titleImageButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadTrendingNews()
        
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
        
        //trendingCollectionView.refreshControl = refreshControl
        
        
        // NotificationCenter에 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateKeywordCollectionView), name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateKeywordCollectionViewAfterDeleteButtonPressed), name: Notification.Name("UpdateKeywordCollectionViewDeleteButtonPressed"), object: nil)
        
    }
    
    func loadVideoSearchArray(completion: @escaping () -> Void) {
        // 데이터 로딩 작업 수행
        if dataStore.loadedVideoSearchArray.isEmpty {
            // 데이터가 없는 경우에 대한 처리
            print("No data found in loadedVideoSearchArray")
            completion()
            return
        }

        // 데이터 로딩이 완료되면 completion closure 호출
        completion()
    }

    func loadData() {

        loadVideoSearchArray {
            // 데이터 로딩이 완료되면 호출되는 closure
            // 데이터 로딩 작업 수행
            let arrayCount = DataStore.shared.loadedVideoSearchArray.count
            print("arrayCount: \(arrayCount)")
            
            //self.trendingCollectionView.reloadData()
//            for i in 0...arrayCount-1 {
//                let firstArray = dataStore.loadedVideoSearchArray[i]
//                //print("firstArray: \(firstArray)")
//                self.imageViewSet(cell: CustomizedCollectionViewCell, firstArray: firstArray)
//                //}
//                // 데이터 로딩 완료 후 refreshControl 비활성화
//                self?.refreshControl.endRefreshing()
//
//                // 나머지 코드 실행
//
//
//            }
        }
        // 데이터 로딩 완료 후 refreshControl 비활성화
        self.refreshControl.endRefreshing()
    }
    
    func initRefresh() {
        //refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        
        refreshControl.backgroundColor = .yellow
        refreshControl.tintColor = .purple
        refreshControl.attributedTitle = NSAttributedString(string: "사진을 불러오는 중입니다")
        
        trendingCollectionView.refreshControl = refreshControl
    }
    
    func loadTrendingNews() { // 주요 기사 불러오기
        print("loadTrendingNews 진입")
        apiNewsSearch(query: Constants.K.headlineNews, count: 10, mkt: mkt, offset: DataStore.shared.newsOffset)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.trendingCollectionView.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //configureButtonView()
        
        self.navigationController?.navigationBar.topItem?.title = ""// #\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        registerXib()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func updateKeywordCollectionView() {
        print("@objc func updateKeywordCollectionView()")
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
        }
    }
    
    @objc func updateKeywordCollectionViewAfterDeleteButtonPressed() {
        print("@objc func updateKeywordCollectionViewAfterDeleteButtonPressed()")
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
        }
    }
    
    private func configureButtonView() {
        
        let titleImageView = UIImageView(image: UIImage(named: "Image"))
        titleImageButton.addSubview(titleImageView)
        self.view.addSubview(titleImageButton)
        
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        titleImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        //titleImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        
        titleImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleImageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -10).isActive = true
        titleImageButton.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        titleImageButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
//        titleImageButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        titleImageButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //titleImageButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -100).isActive = true
        titleImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35).isActive = true

    }

    @objc private func titleImageButtonTapped() {
        // 세그를 실행하는 로직을 구현하세요
        print("titleImageButtonTapped!")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "SignupViewController")
        mainViewController.modalPresentationStyle = .automatic
        self.show(mainViewController, sender: nil)
        
        //self.tabBarController?.selectedIndex = 3
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        let nibName1 = UINib(nibName: "CustomizedCollectionViewCell", bundle: nil)
        trendingCollectionView.register(nibName1, forCellWithReuseIdentifier: "CustomizedCollectionViewCell")
        
        let nibName2 = UINib(nibName: "KeywordCollectionViewCell", bundle: nil)
        keywordCollectionView.register(nibName2, forCellWithReuseIdentifier: "KeywordCollectionViewCell")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        
        if collectionView.tag == 1 {
            if indexPath.row == 0 {// 세그할 때, 클릭한 셀의 키워드 이름을 전달하고, 그 키워드 이름으로 api 콜을 실행해야 함
                performSegue(withIdentifier: "ArchiveToKeywordRegister", sender: self)
                //self.tabBarController?.selectedIndex = 1
            } else {
                performSegue(withIdentifier: "ArchiveToReading", sender: indexPath.row)
            }
        } else {
            performSegue(withIdentifier: "ArchiveToReading", sender: self)
        }
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
            
            let imageArray = ["Ellipse Black", "Ellipse Blue", "Ellipse Dark Gray", "Ellipse Green", "Ellipse Light Gray", "Ellipse Orange", "Ellipse Red", "Ellipse Sky", "Ellipse Yellow"]
            let randomNumber = arc4random_uniform(9)
            
            let image = UIImage(named: imageArray[Int(randomNumber)])

            // cell[indexPath.row = 0]은 반드시 키워드 추가 버튼으로 되어야 함
            
            print("dataStore.userInputKeyword: \(dataStore.userInputKeyword)")
            if dataStore.userInputKeyword != [] { // dataStore에 데이터가 있으므로 그대로 키워드를 불러오면 됨
                if indexPath.row == 0 {
                    cell.ellipseView.image = UIImage(named: "keywordAdd")
                    cell.firstLetterLabel.text = "+"
                    cell.keywordLabel.text = "키워드 추가"
                    
                } else {
                    let keyword = dataStore.userInputKeyword[indexPath.row-1]
                    let firstLetter = String(describing: keyword.first!) // 빈칸만 넣으면 옵셔널 에러가 발생하므로 빈칸, 특수기호만을 넣지 않도록 유도 필요
                    cell.configure(withImage: image, keyword: keyword, firstLetter: firstLetter)
                }
            } else { // dataStore.userInputKeyword == [] //dataStore에 데이터가 없으므로 placeholder를 노출해야 됨.

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
            }
            
            let loadedNewsSearchArray = DataStore.shared.loadedNewsSearchArray // 데이터 읽어오기
            
            if DataStore.shared.loadedNewsSearchArray.count != 0 {
                if indexPath.row == 1 { // 광고 삽입되는 셀
                    cell.thumbnailImageView.image = UIImage(named: "Ellipse Black")
                    cell.contentTextView.text = "광고 삽입되는 자리"
                    cell.contentTextView.tintColor = .white
                    cell.dateLabel.text = ""
                    cell.queryLabel.text = ""
                    cell.distributorLabel.text = ""

                    return cell
                    
                } else if indexPath.row < 1 { // 광고 삽입 이전의 셀

                    let firstArray = loadedNewsSearchArray[indexPath.row]
                    imageViewSet(cell: cell, firstArray: firstArray)
                    
                    return cell
                    
                } else { // 광고 삽입 이후의 셀
                    
                    let firstArray = loadedNewsSearchArray[indexPath.row-1]
                    imageViewSet(cell: cell, firstArray: firstArray)
                    
                    return cell
                }
            } else {
                cell.thumbnailImageView.image = UIImage(named: "Ellipse Black")
                cell.contentTextView.text = "광고 삽입되는 자리"
                cell.contentTextView.tintColor = .white
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
  
        // 셀 초기화 및 데이터 업데이트
        clearTrendingCollectionView()
        loadTrendingNews()
    }
    func clearTrendingCollectionView() {
        // trendingCollectionView의 데이터를 초기화
        DataStore.shared.loadedVideoSearchArray = []
        // trendingCollectionView 리로드
        DispatchQueue.main.async {
            self.trendingCollectionView.reloadData()
        }
        
    }
    
}

extension AcrhiveViewController {
    
    func imageViewSet(cell: CustomizedCollectionViewCell, firstArray : [APIData.webNewsSearch]){
        var imageUrl = firstArray[0].image.contentUrl // ?? UIImage(named: "AppIcon")
        var imageWidth = firstArray[0].image.width
        var imageHeight = firstArray[0].image.height
        var inputDate = firstArray[0].datePublished
        var title = firstArray[0].name
        var distributor = firstArray[0].provider.name
        var url = firstArray[0].webSearchUrl
        
        cell.queryLabel.text = "#\(Constants.K.headlineNews)"
        cell.contentTextView.text = title
        cell.distributorLabel.text = distributor
        
        //"2023-06-13T02:48:00.0000000Z" // 뉴스
        //"2023-05-24T10:37:40.0000000" // 영상
        
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
        
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Error: No image data.")
                return
            }
            // 다운로드한 데이터를 UIImage로 변환
            guard let image = UIImage(data: data) else {
                print("Error: Cannot convert data to image.")
                return
            }
            
            let noiseReducedImage = self.Image_ReduceNoise(image: image)
            let sharpnessEnhancedImage = self.Image_EnhanceSharpness(image: noiseReducedImage!)
            
            // UI 업데이트는 메인 스레드에서 처리
            DispatchQueue.main.async {
                
                let backgroundImageView = UIImageView(image: sharpnessEnhancedImage) // 배경으로 블러 처리할 이미지 불러오기
                backgroundImageView.contentMode = .scaleAspectFill
                //backgroundImageView.clipsToBounds = true
                
                let blurEffect = UIBlurEffect(style: .regular)
                let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
                
                backgroundImageView.frame = cell.bounds
                viewBlurEffect.frame = backgroundImageView.frame

                for subview in backgroundImageView.subviews { // 배경에 넣기 전 배경 초기화
                    subview.removeFromSuperview()
                }

                cell.containerView.addSubview(backgroundImageView)
                cell.containerView.addSubview(viewBlurEffect)
                
                // 하단 그라디언트 추가
                let newView1 = UIView()
                newView1.frame = cell.bounds
                newView1.setGradient(color1: .clear, color2: .black, location1: 0.0, location2: 0.6, location3: 1.0, startPoint1: 0.5, startPoint2: 0.5, endPoint1: 0.5, endPoint2: 1.0)
                
                cell.containerView1.addSubview(newView1)
                
                // 상단 그라디언트 추가
                let newView2 = UIView()
                newView2.frame = cell.bounds
                newView2.setGradient(color1: .black, color2: .clear, location1: 0.0, location2: 0.5, location3: 1.0, startPoint1: 0.5, startPoint2: 0.0, endPoint1: 0.5, endPoint2: 0.2)
                
                cell.containerView1.addSubview(newView2)
                
                cell.contentView.addSubview(cell.containerView)
                cell.contentView.sendSubviewToBack(cell.containerView)
                
                cell.contentView.addSubview(cell.containerView1)
                cell.contentTextView.sendSubviewToBack(cell.containerView1)
                
                cell.contentView.bringSubviewToFront(cell.contentTextView)
                cell.contentView.bringSubviewToFront(cell.verticalStackView)
                    
                cell.thumbnailImageView.image = image
                cell.contentTextView.contentOffset = .zero
                
                NSLayoutConstraint.activate([

                    cell.contentTextView.topAnchor.constraint(equalTo: cell.bottomAnchor, constant: -155),
                    cell.contentTextView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -15),
                ])
                // 이미지 축소 및 적절한 contentMode 설정
                if imageWidth == 0 || imageHeight == 0 {
                    imageWidth = Int(cell.superview!.frame.width)
                    imageHeight = Int(cell.superview!.frame.height)
                    let imageSize = CGSize(width: imageWidth, height: imageHeight)
                    let imageViewSize = cell.thumbnailImageView.frame.size
                    let scaledImageSize = imageSize.aspectFit(to: imageViewSize)
                    cell.thumbnailImageView.frame.size = scaledImageSize
                    
                }
            }
        }
        task.resume()
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
            let cellWidth = collectionView.bounds.width - 40
            //let cellWidth = collectionView.bounds.width * 2.0
            let cellHeight = collectionView.bounds.height
            return CGSize(width: cellWidth , height: cellHeight)
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
            if dataStore.userInputKeyword.isEmpty {
                return 1 // 데이터가 없으면 Placeholder를 위한 셀을 1개 반환
                
            } else {
                return dataStore.userInputKeyword.count + 1 // 데이터가 있으면 실제 데이터 개수 반환
            }
        } else { // collectionView.tag == 2
            
            if DataStore.shared.loadedNewsSearchArray.count != 0 {
                return dataStore.loadedNewsSearchArray.count + 1 // 데이터가 있으면 실제 데이터 개수 반환
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
