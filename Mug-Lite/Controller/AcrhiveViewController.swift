//
//  AcrhiveViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//
import Foundation
import UIKit

class AcrhiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let mkt = "ko-KR"
    
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
    var count = 0
    var totalEstimatedResults = 0
    var offset = 0
    let mainVC = MainViewController()
    
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 700
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("loadedVideoSearchArray: \(loadedVideoSearchArray)")
        self.navigationController?.navigationBar.topItem?.title = "#\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = true

        self.navigationItem.largeTitleDisplayMode = .always
        registerXib()
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        let nibName = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CustomTableViewCell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let cellHeightRatio: CGFloat = 0.81 // 셀의 화면 비율 (0.5는 화면의 절반을 의미)
        
        let tabBarHeight = tabBarController?.tabBar.frame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        //let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let margin = view.layoutMarginsGuide
        let window = UIApplication.shared.windows.first { $0.isKeyWindow}
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height
        print("Status bar height: \(String(describing: statusBarHeight))")
        
        let windows = UIApplication.shared.windows.first
        let top = windows?.safeAreaInsets.top
        let bottom = windows?.safeAreaInsets.bottom
        //let height = top - bottom
        print("top : \(String(describing: top))")
        print("bottom : \(String(describing: bottom))")
        
        //let heightofRowHeight = screenHeight - tabBarHeight! - statusBarHeight! - 5
        let heightofRowHeight = screenHeight - tabBarHeight! - top!
        
        return heightofRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 데이터 읽어오기

        let firstArray = loadedVideoSearchArray[indexPath.row]
//        let secondArray = firstArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        //cell.keywordLabel?.text = firstArray[0].query
        //cell.titleLabel?.text = firstArray[0].name
        //cell.feedImageView.image = UIImage(contentsOfFile: firstArray[0].thumbnailUrl)
        let tabBarHeight = tabBarController?.tabBar.frame.height
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        
//        DispatchQueue.main.async {
//            NSLayoutConstraint.activate([
//                cell.contentTextView.bottomAnchor.constraint(equalTo: cell.dateLabel.bottomAnchor, constant: 30),
//                cell.contentTextView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
//                cell.contentTextView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 20)
//            ])
//        }
        
        var imageUrl = firstArray[0].thumbnailUrl
        var imageWidth = firstArray[0].width
        var imageHeight = firstArray[0].height
        
        var date = firstArray[0].datePublished
        
        cell.queryLabel.text = Constants.K.query
        cell.dateLabel.text = date
        cell.contentTextView.text = "에효 뭐가 이리도 안되는 건지"
    
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
                // 이미지 뷰에 이미지 설정
                //cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentTextView.contentOffset = .zero
                //cell.contentView.translatesAutoresizingMaskIntoConstraints = false
                
                let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
//                let screenHeight = UIScreen.main.bounds.height
//                print(cell.heightAnchor)
//                print("screenHeight: \(screenHeight)")
//                let cellHeightRatio: CGFloat = 0.95
                
                NSLayoutConstraint.activate([
                    //cell.heightAnchor.constraint(equalToConstant: screenHeight * cellHeightRatio),
                    
                    cell.thumbnailImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    cell.thumbnailImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    cell.thumbnailImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    cell.thumbnailImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    
                    //cell.thumbnailImageView.heightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
                    //cell.urlButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                    //cell.keywordLabel.heightAnchor.constraint(equalToConstant: 30),
                    //cell.titleLabel.heightAnchor.constraint(equalToConstant: 60),
                    //cell.contentTextView.heightAnchor.constraint(equalToConstant: 90),
                    //cell.urlButton.heightAnchor.constraint(equalToConstant: 40),
                    //cell.urlButton.topAnchor.constraint(equalTo: cell.contentTextView.bottomAnchor, constant: 0)
                ])
                
                // 이미지 축소 및 적절한 contentMode 설정
                if imageWidth == 0 || imageHeight == 0 {
                    imageWidth = 200
                    imageHeight = 200
                    let imageSize = CGSize(width: imageWidth, height: imageHeight)
                    let imageViewSize = cell.thumbnailImageView.frame.size
                    let scaledImageSize = imageSize.aspectFit(to: imageViewSize)
                    cell.thumbnailImageView.frame.size = scaledImageSize
                    cell.thumbnailImageView.contentMode = .scaleAspectFit
                }
                cell.thumbnailImageView.image = image
            }
        }
        task.resume()
    
        //cell.contentTextView?.text = firstArray[0].description
        //cell.urlButton?.titleLabel?.text = firstArray[0].webSearchUrl
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        //navigationController?.navigationBar.sizeToFit()
        
        return cell
    }

    
    func dispatchQueue() {
        DispatchQueue.main.async {
            if self.tableView != nil {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
                print("dispatchQueue 완료!")
            } else {
                print("self.letterTableView에 nil 출력")
            }
        }
    }

}
