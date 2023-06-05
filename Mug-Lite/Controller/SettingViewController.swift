//
//  SettingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var settingTableView: UITableView!
    
    let tableViewMenuArray = ["피드백 보내기", "문의하기", "스토어 별점 남기기", "이용약관 및 개인정보 처리방침", "홈페이지", "광고 문의"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.topItem?.title = "설정"// #\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        tableViewConfigure()
    }
    
    private func tableViewConfigure() {
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewMenuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        
        cell.tableViewCellLabel.text = tableViewMenuArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        switch indexPath.row
        {
        case 0:
            print("피드백 보내기")
        case 1:
            print("문의하기")
        case 2:
            print("스토어 별점 남기기")
        case 3:
            print("이용약관 및 개인정보 처리방침")
        case 4:
            print("홈페이지")
        case 5:
            print("광고 문의")
        default:
            print("Error!")
        }
        
        
    }

}
