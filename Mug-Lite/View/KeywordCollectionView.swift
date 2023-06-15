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
        // ...
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // ...
    }
    
    //@objc private func updateKeywordCollectionViewAfterDeleteButtonPressed(_ notification: Notification) {
        // 업데이트할 동작을 여기에 구현합니다.

    //}
}

