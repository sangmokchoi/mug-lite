//
//  BookmarkViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    let apiData = APIData.Bookmarked()
    var bookmarkArray : [[APIData.Bookmarked]] = [
        [APIData.Bookmarked(query: "밤편지", name: "밤편지의 대성공, 머그라이트로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "경향신문")],
        [APIData.Bookmarked(query: "머그라이트", name: "머그라이트의 대성공, 프로젝트인으로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "JTBC")],
        [APIData.Bookmarked(query: "프로젝트인", name: "프로젝트인의 대성공, 목성다리로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "한겨레")],
        [APIData.Bookmarked(query: "목성다리", name: "목성다리의 대성공, 주식회사 사이먼워크로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "뉴욕타임즈")],
        [APIData.Bookmarked(query: "사이먼워크", name: "사이먼워크의 대성공, IPO로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "BBC")]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        
        print("bookmarkArray[0]: \(bookmarkArray[0][0].name)")
    }
    
    private func configure() {
        bookmarkTableView.dataSource = self
        bookmarkTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell
        
        cell.titleLabel.text = bookmarkArray[indexPath.row][0].name
        cell.dateLabel.text = bookmarkArray[indexPath.row][0].datePublished
        cell.keywordLabel.text = "#\(bookmarkArray[indexPath.row][0].query)"
        cell.distributorLabel.text = bookmarkArray[indexPath.row][0].distributor
        
        return cell
    }

}
