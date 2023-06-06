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
    @IBOutlet weak var distributorLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var verticalStackView: UIStackView!
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: contentView.bounds)
        return containerView
    }()
    
    lazy var containerView1: UIView = {
        let containerView1 = UIView(frame: contentView.bounds)
        return containerView1
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀이 재사용될 때 초기화 로직을 여기에 추가합니다.
        thumbnailImageView.image = nil
        queryLabel.text = nil
        dateLabel.text = nil
        contentTextView.text = nil
        
        for subview in containerView.subviews {
            print("for subview in containerView.subviews 진입")
            subview.removeFromSuperview()

        }
        for subview in containerView1.subviews {
            print("for subview in containerView1.subviews 진입")
            subview.removeFromSuperview()
            //removeAllSubviews()
        }
    }
}

extension UIView {
    func setGradient(color1: UIColor, color2: UIColor, location1: NSNumber, location2: NSNumber, location3: NSNumber, startPoint1: CGFloat, startPoint2: CGFloat, endPoint1: CGFloat, endPoint2: CGFloat){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [location1, location2, location3]
        gradient.startPoint = CGPoint(x: startPoint1, y: startPoint2)
        gradient.endPoint = CGPoint(x: endPoint1, y: endPoint2)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}
