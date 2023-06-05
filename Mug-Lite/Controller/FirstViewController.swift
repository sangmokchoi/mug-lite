//
//  FirstViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/24.
//

import UIKit

class FirstViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let loadedVideoSearchArray = DataStore.shared.loadedVideoSearchArray // 데이터 읽어오기

        let firstArray = loadedVideoSearchArray[indexPath.row]
//        let secondArray = firstArray[indexPath.row]
        
        let cell = trendingKeywordsCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomTableViewCell", for: indexPath) as! CustomizedCollectionViewCell

        let tabBarHeight = tabBarController?.tabBar.frame.height
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        
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
                cell.contentTextView.contentOffset = .zero
                
                let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide

                NSLayoutConstraint.activate([
                    cell.thumbnailImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    cell.thumbnailImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    cell.thumbnailImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                    cell.thumbnailImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                    
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
        
        //cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        //navigationController?.navigationBar.sizeToFit()
        
        return cell
    }
    

    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var trendingKeywordsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordCollectionView.dataSource = self
        keywordCollectionView.delegate = self
        trendingKeywordsCollectionView.dataSource = self
        trendingKeywordsCollectionView.delegate = self
        // Do any additional setup after loading the view.
    }

    
}
