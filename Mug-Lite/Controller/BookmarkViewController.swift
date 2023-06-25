//
//  BookmarkViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit
import SafariServices

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var bookmarkTableView: UITableView!
    
    let apiData = APIData.Bookmarked()
    var bookmarkArray : [[APIData.Bookmarked]] = [
        [APIData.Bookmarked(query: "밤편지", url: "https://", name: "밤편지의 대성공, 머그라이트로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "경향신문")],
        [APIData.Bookmarked(query: "머그라이트", url: "https://", name: "머그라이트의 대성공, 프로젝트인으로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "JTBC")],
        [APIData.Bookmarked(query: "프로젝트인", url: "https://", name: "프로젝트인의 대성공, 목성다리로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "한겨레")],
        [APIData.Bookmarked(query: "목성다리", url: "https://", name: "목성다리의 대성공, 주식회사 사이먼워크로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "뉴욕타임즈")],
        [APIData.Bookmarked(query: "사이먼워크", url: "https://", name: "사이먼워크의 대성공, IPO로 그 발걸음을 이끌어", datePublished: "2023-06-01 13:00", distributor: "BBC")]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NotificationCenter에 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(updateBookmarkTableView), name: Notification.Name("updateBookmarkTableView"), object: nil)
        //print("DataStore.shared.bookmarkArray: \(DataStore.shared.bookmarkArray)")
        DispatchQueue.main.async {
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
}
