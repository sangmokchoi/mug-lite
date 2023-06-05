//
//  KeywordCollectionViewHeader.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/27.
//

import UIKit

class KeywordCollectionView: UICollectionViewCell {
        
    @IBOutlet weak var keywordLabel: UILabel!
    private var deleteButton: UIButton! // 버튼 추가
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //setupDeleteButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setupDeleteButton()
    }
    
    @objc private func deleteButtonTapped() {
        // 버튼이 눌렸을 때 수행할 동작을 여기에 구현합니다.
        // 예를 들어, 해당 키워드를 삭제하는 로직을 추가할 수 있습니다.
        print("Delete button tapped")
    }
}

