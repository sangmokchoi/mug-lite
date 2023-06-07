//
//  KeywordRegisterViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit
import OHCubeView

class KeywordRegisterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var keywordSearchBar: UISearchBar!
    @IBOutlet weak var followingKeywordCountLabel: UILabel!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    
    var userInputKeyword : String = ""
    
    var userData = UserData()
    let dataStore = DataStore.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordCollectionView.dataSource = self
        keywordCollectionView.delegate = self
        
        registerXib()
        configure()
    }
    
    func configure() {
        keywordCollectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        if let flowLayout = keywordCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
          }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var followingKeywordCount : Int = dataStore.userInputKeyword.count
        followingKeywordCountLabel.text = "팔로잉 키워드: \(followingKeywordCount) /20"
        
    }
    
    private func registerXib() { // 커스텀한 테이블 뷰 셀을 등록하는 함수
        
        let nibName2 = UINib(nibName: "KeywordCollectionView", bundle: nil)
        keywordCollectionView.register(nibName2, forCellWithReuseIdentifier: "KeywordCollectionView")
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        // 서버에 연동할 때 사용
        
        //        if let userInputKeyword = keywordSearchBar.text {
        //            userData.userInputKeyword.append(userInputKeyword)
        //        }
        
        // 임시로 개발 중에 시뮬레이터에 저장하고자 사용
        if let userInputKeyword = keywordSearchBar.text {
            if !dataStore.userInputKeyword.contains(userInputKeyword) { // 배열에 유저가 입력한 키워드가 없으므로 그대로 진행
                dataStore.userInputKeyword.append(userInputKeyword)
                self.userInputKeyword = userInputKeyword
            } else { // 배열에 유저가 입력한 키워드가 있으므로 재입력 필요
                alert1(title: "동일한 키워드가 있어요", message: "다른 키워드를 입력해주세요", actionTitle1: "확인")
                DispatchQueue.main.async {
                    self.keywordSearchBar.text = ""
                }
            }
        }
        print("dataStore.userInputKeyword: \(dataStore.userInputKeyword)")
        
        DispatchQueue.main.async {
            self.keywordCollectionView.reloadData()
            NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionView"), object: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //return UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.userInputKeyword.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let addedKeyword = dataStore.userInputKeyword[indexPath.row]
        let keywordLabelWidth = addedKeyword.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]).width

        let cellWidth = keywordLabelWidth + 30 // 키워드 레이블의 너비와 여백을 더한 값으로 셀의 너비 설정
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = keywordCollectionView.dequeueReusableCell(withReuseIdentifier: "KeywordCollectionView", for: indexPath) as! KeywordCollectionView
        
        let deleteButton = UIButton(type: .close)
        //deleteButton.setTitle("x", for: .normal)
        //deleteButton.setImage(UIImage(named: "xmark"), for: .normal)
        let scaleRatio: CGFloat = 0.4
        deleteButton.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        deleteButton.contentMode = .scaleAspectFit
        deleteButton.setTitleColor(.systemGray, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        cell.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.leadingAnchor.constraint(equalTo: cell.keywordLabel.trailingAnchor, constant: -5).isActive = true
        //deleteButton.trailingAnchor.constraint(equalTo: cell.keywordLabel.trailingAnchor, constant: -10).isActive = true
        //deleteButton.centerYAnchor.constraint(equalTo: cell.keywordLabel.centerYAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: cell.keywordLabel.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: cell.keywordLabel.bottomAnchor).isActive = true
        
        //let layoutLine =
        cell.layer.cornerRadius = 12
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.systemGray.cgColor
        
        let addedKeyword = dataStore.userInputKeyword[indexPath.row]
        cell.keywordLabel.text = addedKeyword
        
        return cell
    }
    
    @objc private func deleteButtonTapped(sender: UIButton) {
        // 버튼이 눌렸을 때 수행할 동작을 여기에 구현합니다.
        print("Delete button tapped")
        
        let alertController = UIAlertController(title: "키워드 삭제", message: "선택한 키워드를 삭제합니다", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "삭제", style: .destructive) { UIAlertAction in
            print("삭제 버튼 클릭")
            guard let cell = sender.superview as? KeywordCollectionView else {
                print("cell에 문제 있음")
                return
            }
            // 셀의 인덱스를 찾습니다.
            guard let indexPath = self.keywordCollectionView.indexPath(for: cell) else {
                print("indexPath에 문제 있음")
                return
            }
            // 해당 키워드 값을 dataStore.userInputKeyword에서 삭제합니다.
            self.dataStore.userInputKeyword.remove(at: indexPath.row)
            // collectionView에서 해당 셀을 삭제합니다.
            self.keywordCollectionView.deleteItems(at: [indexPath])
            NotificationCenter.default.post(name: Notification.Name("UpdateKeywordCollectionViewDeleteButtonPressed"), object: nil)

//            DispatchQueue.main.async {
//                // collectionView에서 해당 셀을 삭제합니다.
//                self.keywordCollectionView.deleteItems(at: [indexPath])
//                self.keywordCollectionView.reloadData()
//            }
            print("index.path: \(indexPath.row)")
            print("self.dataStore.userInputKeyword: \(self.dataStore.userInputKeyword)")
        }
        let action2 = UIAlertAction(title: "취소", style: .default)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // 셀 간의 세로 간격
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //셀 간의 가로 간격
        return 5
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       // 현재 검색 바의 텍스트와 새로 입력된 문자를 조합하여 최종 문자열을 얻습니다.
       guard let currentText = searchBar.text else { return true }
       let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
       // 최종 문자열의 길이가 25자 이하인지 확인합니다.
       return updatedText.count <= 25
   }
    
    

}

extension UIViewController {
    func alert1(title: String, message: String, actionTitle1: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: actionTitle1, style: .default)
        alertController.addAction(action1)
        self.present(alertController, animated: true)
    }
    
    func alert2(title: String, message: String, actionTitle1: String, actionTitle2: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: actionTitle1, style: .destructive)
        let action2 = UIAlertAction(title: actionTitle2, style: .default)
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true)
    }
}


