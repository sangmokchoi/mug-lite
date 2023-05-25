//
//  MainViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import UIKit

class MainViewController: UIViewController {
    
    var loadedNewsSearchArray : [[APIData.webNewsSearch]] = []
    // 형식: [newsSearchArray, newsSearchArray, newsSearchArray]
    var newsSearchArray : [APIData.webNewsSearch] = []
    
    var loadedVideoSearchArray : [[APIData.webVideoSearch]] = []
    // 형식: [videoSearchArray, videoSearchArray, videoSearchArray]
    var videoSearchArray : [APIData.webVideoSearch] = []
    
    let cellSpacingHeight: CGFloat = 1
    @IBOutlet weak var imageView: UIImageView!
    
    let mkt = "ko-KR"
    //let query = "유재석" // "주요 기사" - 최근 주요 기사 불러오는 키워드
    var count = 0
    var totalEstimatedResults = 0
    var offset = 0
    
    let parser = MyXMLParser()
    let apiManager = APIManager()
    //let archiveVC = AcrhiveViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiVideoSearch(query: Constants.K.query, count: 10, mkt: mkt, offset: offset)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // <b></b> : 볼드처리 의미
        // &#39; : 작은 따옴표(single quote)
        // &quot; : 큰 따옴표(double quote)
    }
    
    @IBAction func refresh(_ sender: UIButton) { // 실 서비스에서는 스크롤 이후 refresh가 진행되어야 함
        if self.offset <= self.totalEstimatedResults - self.count {
            print("offset: \(self.offset)")
            print("totalEstimatedResults: \(self.totalEstimatedResults)")
            //apiNewsSearch(query: query, count: 10, mkt: mkt, offset: offset)
            //apiVideoSearch(query: query, count: count, mkt: mkt, offset: offset)
        } else {
            print("더이상 불러올 수 없습니다")
        }
        
    }
    
    @IBAction func callIamge(_ sender: UIButton) {
        //thumbnailImageCall()
    }
    
    @IBAction func imageChange(_ sender: UIButton) {
        //thumbnailImageChange()
    }
}


