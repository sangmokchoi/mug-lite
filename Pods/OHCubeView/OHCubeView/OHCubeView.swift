//
//  OHCubeView.swift
//  CubeController
//
//  Created by Øyvind Hauge on 11/08/16.
//  Copyright © 2016 Oyvind Hauge. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
@objc protocol OHCubeViewDelegate: class {
    
    @objc optional func cubeViewDidScroll(_ cubeView: OHCubeView)
}

@available(iOS 9.0, *)
open class OHCubeView: UIScrollView, UIScrollViewDelegate {
    
    weak var cubeDelegate: OHCubeViewDelegate?
    private var isScrolling = false
    
    fileprivate let maxAngle: CGFloat = 60.0
    
    fileprivate var childViews = [UIView]()
    
    fileprivate lazy var stackView: UIStackView = {
        
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = NSLayoutConstraint.Axis.horizontal
        
        return sv
    }()
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        configureScrollView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureScrollView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open func getChildViewsCount() -> Int {
        //print("childViews.count: \(childViews.count)")
        return childViews.count
    }
    
    open func printChildViews() {
        for view in childViews {
            print("view: \(view)")
        }
    }
    
    open func removeChildViews() {
        for view in childViews {
            view.removeFromSuperview()
        }
    }
    
    open func addChildViews(_ views: [UIView]) {
        let viewsCount = views.count
        
        for view in views {
            view.layer.masksToBounds = true
            stackView.addArrangedSubview(view)
            //view.tag = childViews.count
            //print("view.tag: \(view.tag)")
            //print("childViews.count: \(childViews.count)")
            // print("stackView.subviews: \(stackView.subviews)")
            
//            if view == views.first {
//                print("first view: \(view)")
//                let leadingConstraint = view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
//                leadingConstraint.isActive = true
//            }
            
            addConstraint(NSLayoutConstraint(
                item: view,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: self,
                attribute: NSLayoutConstraint.Attribute.width,
                multiplier: 1,
                constant: 0)
            )
            childViews.append(view)
            //transformViewsInScrollView(self)
        }
        
    }
    
    open func addChildView(_ view: UIView) {
        addChildViews([view])
    }
    
    open func scrollToViewAtIndex(_ index: Int, animated: Bool) {
        if index > -1 && index < childViews.count {
            
            let width = self.bounds.size.width
            let height = self.bounds.size.height
            
            let frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
            self.scrollRectToVisible(frame, animated: animated)
        }
    }
    
    // MARK: Scroll view delegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        transformViewsInScrollView(scrollView)
        cubeDelegate?.cubeViewDidScroll?(self)
        let subviews = scrollView.subviews
        
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        var direction: UISwipeGestureRecognizer.Direction
        
        if velocity.x > 0 {
            // 오른쪽 스와이프
            direction = .right
        } else {
            // 왼쪽 스와이프
            direction = .left
        }
        
        NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil, userInfo: ["direction": direction])
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // 스크롤 동작이 끝날 때 호출되는 메서드
            // 스크롤 동작을 감지하고 필요한 동작을 처리할 수 있습니다.
        }
    
    // MARK: Private methods
    fileprivate func configureScrollView() {
        
        // Configure scroll view properties
        backgroundColor = UIColor.black
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isPagingEnabled = true
        bounces = true
        delegate = self
        
        // Add layout constraints
        addSubview(stackView)
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.leading,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.leading,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.height,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.centerY,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.centerY,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.trailing,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: stackView,
            attribute: NSLayoutConstraint.Attribute.trailing,
            multiplier: 1,
            constant: 0)
        )
        
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: stackView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1,
            constant: 0)
        )
    }
    
    fileprivate func transformViewsInScrollView(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let svWidth = scrollView.frame.width
        var deg = maxAngle / bounds.size.width * xOffset
        
        for index in 0 ..< childViews.count {
            
            let view = childViews[index]
            deg = index == 0 ? deg : deg - maxAngle
            let rad = deg * CGFloat(Double.pi / 180)
            
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            
            var transform = CATransform3DIdentity
            transform.m34 = 1 / 500
            transform = CATransform3DRotate(transform, rad, 0, 1, 0)
            
            view.layer.transform = transform
            
            let x = xOffset / svWidth > CGFloat(index) ? 0.5 : 0.5
            setAnchorPoint(CGPoint(x: x, y: 0.5), forView: view)
            
            applyShadowForView(view, index: index)
        }
    }
    
    fileprivate func applyShadowForView(_ view: UIView, index: Int) {
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        let r1 = frameFor(origin: contentOffset, size: self.frame.size)
        let r2 = frameFor(origin: CGPoint(x: CGFloat(index)*w, y: 0),
                          size: CGSize(width: w, height: h))
        
        // Only show shadow on right-hand side
        if r1.origin.x <= r2.origin.x {
            
            let intersection = r1.intersection(r2)
            let intArea = intersection.size.width*intersection.size.height
            let union = r1.union(r2)
            let unionArea = union.size.width*union.size.height
            
            view.layer.opacity = Float(intArea / unionArea)
        }
    }
    
    fileprivate func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
        
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    fileprivate func frameFor(origin: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}
