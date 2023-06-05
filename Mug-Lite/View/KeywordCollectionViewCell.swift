//
//  KeywordCollectionViewCell.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/26.
//

import UIKit

class KeywordCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ellipseView: UIImageView!
    @IBOutlet weak var firstLetterLabel: UILabel!
    @IBOutlet weak var keywordLabel: UILabel!
    
    // 이미지를 저장할 프로퍼티 추가
    private var ellipseImage: UIImage?

    // ...

    func configure(withImage image: UIImage?, keyword: String, firstLetter: String) {
        // 이미지 설정
        ellipseImage = image
        ellipseView.image = ellipseImage

        // 텍스트 설정
        keywordLabel.text = keyword
        firstLetterLabel.text = firstLetter
    }
    
}
