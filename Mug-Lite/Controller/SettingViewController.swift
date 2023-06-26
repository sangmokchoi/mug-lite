//
//  SettingViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingTableView: UITableView!
    
    let tableViewMenuArray = ["피드백 보내기", "문의하기", "스토어 별점 남기기", "이용약관 및 개인정보 처리방침", "홈페이지", "회원 탈퇴", "광고 문의"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") {
            if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                if userEmail.contains("google") {
                    print("구글 로그아웃")
                } else {
                    print("애플 로그아웃")
                }
            }
            profileButton.titleLabel?.text = "로그아웃"
        } else {
            profileButton.titleLabel?.text = "로그인하기"
        }
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.topItem?.title = "설정"// #\(Constants.K.query)"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backItem?.title = ""
        
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        settingTableView.showsVerticalScrollIndicator = false
        
        tableViewConfigure()
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        
        if let userUid = UserDefaults.standard.string(forKey: "uid") { // 로그인이 된 상태이므로 로그아웃을 해야함
            
            let alertController = UIAlertController(title: "로그아웃 하시겠습니까?", message: "로그아웃을 ", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
                // 로그아웃을 위한 함수 구현 필요
                if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
                    if userEmail.contains("google") {
                        print("구글 로그아웃")
                    } else {
                        print("애플 로그아웃")
                    }
                    DispatchQueue.main.async {
                        self.profileButton.titleLabel?.text = "로그인하기"
                    }
                }
            }
            let action2 = UIAlertAction(title: "취소", style: .default)
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true)
            
        } else { // 로그인이 안된 상태이므로 로그인을 해야함
            performSegue(withIdentifier: "settingToProfile", sender: sender)
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 클릭된 셀에 대한 처리를 여기에 구현합니다.
        switch indexPath.row
        {
        case 0:
            print("피드백 보내기")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 1:
            print("문의하기")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2:
            print("스토어 별점 남기기")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 3:
            print("이용약관 및 개인정보 처리방침")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 4:
            print("홈페이지")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 5:
            print("회원 탈퇴")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 6:
            print("광고 문의")
            if let url = URL(string: "https://sites.google.com/view/aletterfromlatenightpolicy/%ED%99%88") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            print("Error!")
        }
        
    }

}
