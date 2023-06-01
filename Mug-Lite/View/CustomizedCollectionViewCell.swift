//
//  CustomizedCollectionViewCell.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/05/25.
//

import UIKit

class CustomizedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: contentView.bounds)
        return containerView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀이 재사용될 때 초기화 로직을 여기에 추가합니다.
        thumbnailImageView.image = nil
        queryLabel.text = nil
        dateLabel.text = nil
        contentTextView.text = nil
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
            // 필요한 다른 초기화 작업들을 수행합니다.
            //removeAllSubviews()
        }
    }
    func removeAllSubviews() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }
    
//    override func layoutSubviews() {
//       super.layoutSubviews()
//        
//        contentView.backgroundColor = UIColor.red // 배경 색상을 원하는 색으로 지정합니다.
//   }
}

extension UICollectionViewCell {
    func setGradient(color1:UIColor,color2:UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor,color2.cgColor]
        //gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.75)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}
