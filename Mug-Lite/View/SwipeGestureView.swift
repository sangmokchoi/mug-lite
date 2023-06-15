//
//  SwipeGestureView.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/09.
//

import UIKit

class SwipeGestureView: UIView {

    private var startLocation: CGPoint?
    private let swipeThreshold: CGFloat = 30.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSwipeGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSwipeGestureRecognizer()
    }

    private func addSwipeGestureRecognizer() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        addGestureRecognizer(swipeGesture)
    }

    @objc private func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            return
        }

        let currentLocation = gesture.translation(in: view.superview)

        switch gesture.state {
        case .began:
            startLocation = currentLocation
        case .changed:
            guard let startLocation = startLocation else {
                return
            }

            let dx = currentLocation.x - startLocation.x

            if dx > swipeThreshold {
                // Right swipe detected
                // Handle your logic here
                print("Right swipe")
            } else if dx < -swipeThreshold {
                // Left swipe detected
                // Handle your logic here
                print("Left swipe1")
            }

        case .ended, .cancelled, .failed:
            startLocation = nil
        default:
            break
        }
    }
}

