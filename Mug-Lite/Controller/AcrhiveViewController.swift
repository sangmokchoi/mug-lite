//
//  AcrhiveViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//
import Foundation
import UIKit

class AcrhiveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 플래그 변수
    private var isUIUpdated = false
    
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var trendingNewsLabel: UILabel!
    
    let mkt = "ko-KR"
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
    var count = 0
    var totalEstimatedResults = 0
    var offset = 0
    let mainVC = MainViewController()
    
    var loadedNewsSearchArray : [[APIData.webNewsSearch]] = []
    // 형식: [newsSearchArray, newsSearchArray, newsSearchArray]
    var newsSearchArray : [APIData.webNewsSearch] = []
    
    var loadedVideoSearchArray : [[APIData.webVideoSearch]] = []
    // 형식: [videoSearchArray, videoSearchArray, videoSearchArray]
    var videoSearchArray : [APIData.webVideoSearch] = []
    
    var videoUrlArray : [[String : Any]] = [] // 썸네일 이미지 교체를 위해 필요한 배열
    //loadedVideoSearchArray에서 contentUrlArray의 값을 모으는 딕셔너리
    //형식 : (["height": 0, "contentUrl": "", "width": 0])
    var videoUrlArrayIndex = 0
    
    var contentUrlArray : [[String : Any]] = [] // 썸네일 이미지 교체를 위해 필요한 배열
    //loadedNewsSearchArray에서 contentUrlArray, width, weight의 값들을 모으는 딕셔너리
    //형식 : (["height": 0, "contentUrl": "", "width": 0])
    var contentUrlArrayIndex = 0
    
    let cellSpacingHeight : CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //apiVideoSearch(query: query, count: 10, mkt: mkt, offset: offset)
        //apiNewsSearch(query: query, count: count, mkt: mkt, offset: offset)
        
        keywordCollectionView.delegate = self
        keywordCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        
        keywordCollectionView.tag = 1
        trendingCollectionView.tag = 2
        
        keywordCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = ""// #\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        registerXib()
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        let nibName1 = UINib(nibName: "CustomizedCollectionViewCell", bundle: nil)
        trendingCollectionView.register(nibName1, forCellWithReuseIdentifier: "CustomizedCollectionViewCell")
        
        let nibName2 = UINib(nibName: "KeywordCollectionViewCell", bundle: nil)
        keywordCollectionView.register(nibName2, forCellWithReuseIdentifier: "KeywordCollectionViewCell")
        
        let nibName3 = UINib(nibName: "KeywordCollectionViewHeader", bundle: nil)
        keywordCollectionView.register(nibName3, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "KeywordCollectionViewHeader")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        
        if collectionView.tag == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "ArchiveToKeywordRegister", sender: self)
            } else {
                performSegue(withIdentifier: "ArchiveToReading", sender: self)
            }
        } else {
            performSegue(withIdentifier: "ArchiveToReading", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        if collectionView.tag == 1 {
            
            let cellHeight = collectionView.frame.height - 25
            let cellWidth = cellHeight * 0.75
            return CGSize(width: cellWidth, height: cellHeight)
            
        } else {
            
            // trendingCollectionView의 각 셀 크기 설정
            let cellWidth = collectionView.bounds.width - 40
            //let cellWidth = collectionView.bounds.width * 2.0
            let cellHeight = collectionView.bounds.height
            return CGSize(width: cellWidth , height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        
        if collectionView.tag == 1 { // 키워드 관리 컬렉션 뷰
            let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCollectionViewCell", for: indexPath) as! KeywordCollectionViewCell
            
            DispatchQueue.main.async {
                NSLayoutConstraint.activate([
                    cell.ellipseView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 25),
                    cell.ellipseView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -20),
                    
                    cell.firstLetterLabel.centerXAnchor.constraint(equalTo: cell.ellipseView.centerXAnchor),
                    cell.firstLetterLabel.centerYAnchor.constraint(equalTo: cell.ellipseView.centerYAnchor)
                ])
            }
            
            if indexPath.row == 0 {
                cell.ellipseView.image = UIImage(named: "Ellipse Black")
                cell.keywordLabel.text = "키워드 추가"
                
                return cell
                
            } else {
                
                let imageArray = ["Ellipse Black", "Ellipse Blue", "Ellipse Dark Gray", "Ellipse Green", "Ellipse Light Gray", "Ellipse Orange", "Ellipse Red", "Ellipse Sky", "Ellipse Yellow"]
                let randomNumber = arc4random_uniform(9)
                cell.ellipseView.image = UIImage(named: imageArray[Int(randomNumber)])
                
                let keyword = Constants.K.query
                cell.keywordLabel.text = keyword
                
                let firstLetter = Constants.K.query.first!
                cell.firstLetterLabel.text = String(describing: firstLetter)
                
                return cell
            }
            
        } else { // 오늘의 주요 기사
            
            let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomizedCollectionViewCell", for: indexPath) as! CustomizedCollectionViewCell
            
            DispatchQueue.main.async {
                cell.contentView.translatesAutoresizingMaskIntoConstraints = false
                cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
            }
            
            let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 데이터 읽어오기
            
            if indexPath.row == 2 { // 광고 삽입되는 셀
                cell.thumbnailImageView.image = UIImage(named: "Ellipse Black")
                cell.contentTextView.text = "광고 삽입되는 자리"
                cell.dateLabel.text = ""
                cell.queryLabel.text = ""
                
                return cell
                
            } else if indexPath.row < 2 { // 광고 삽입 이전의 셀
                
                let firstArray = loadedVideoSearchArray[indexPath.row]
                imageViewSet(cell: cell, firstArray: firstArray)
                
                return cell
                
            } else { // 광고 삽입 이후의 셀
                
                let firstArray = loadedVideoSearchArray[indexPath.row-1]
                imageViewSet(cell: cell, firstArray: firstArray)
                
                return cell
            }
            
            //cell.contentTextView?.text = firstArray[0].description
            //cell.urlButton?.titleLabel?.text = firstArray[0].webSearchUrl
            //cell.selectionStyle = UITableViewCell.SelectionStyle.none
            //navigationController?.navigationBar.sizeToFit()
        }
    }
    
}

extension AcrhiveViewController {
    
    func imageViewSet(cell: CustomizedCollectionViewCell, firstArray : [APIData.webVideoSearch]){
        var imageUrl = firstArray[0].thumbnailUrl
        var imageWidth = firstArray[0].width
        var imageHeight = firstArray[0].height
        var inputDate = firstArray[0].datePublished
        var context = firstArray[0].name
        
        cell.queryLabel.text = "#\(Constants.K.query)"
        cell.contentTextView.text = context
        //cell.setGradient(color1: UIColor.clear, color2: UIColor.black)
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = inputFormatter.date(from: inputDate) {
            let outputDate = outputFormatter.string(from: date)
            cell.dateLabel.text = outputDate
            print("outputDate: \(outputDate)")
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
            
            // UI 업데이트는 메인 스레드에서 처리
            DispatchQueue.main.async {
                let subviewsCount = cell.contentView.subviews.count
                print("subviewsCount: \(subviewsCount)")
                
                let backgroundImageView = UIImageView(image: image)
                backgroundImageView.contentMode = .scaleAspectFill
                //backgroundImageView.clipsToBounds = true
                
                let blurEffect = UIBlurEffect(style: .regular)
                let viewBlurEffect = UIVisualEffectView(effect: blurEffect)
                
                backgroundImageView.frame = cell.bounds
                viewBlurEffect.frame = backgroundImageView.frame
                
                
                for subview in backgroundImageView.subviews {
                    subview.removeFromSuperview()
                }

                cell.containerView.addSubview(backgroundImageView)
                cell.containerView.addSubview(viewBlurEffect)
                
                cell.contentView.addSubview(cell.containerView)
                cell.contentView.sendSubviewToBack(cell.containerView)
                    
                cell.thumbnailImageView.image = image
                //cell.contentTextView.contentOffset = .zero
                
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // 아이템 사이의 간격
        if collectionView.tag == 1 {
            return 0
        } else {
            return 2
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 아이템의 개수
        if collectionView.tag == 1 {
            return 10
        } else {
            return 10
        }
        
    }
    
    func numberOfRows(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 1 {
            return 10
        } else {
            return 8
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // 아이템들 사이의 가로 간격
        if collectionView.tag == 1 {
            return 0
        } else {
            return 10
        }
    }
}
