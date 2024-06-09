//
//  CustomUIGestureRecognizer.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/09.
//

import UIKit.UIGestureRecognizerSubclass

class CustomUIGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        // 터치 이동 변위를 초기화합니다.
        setTranslation(.zero, in: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        // 터치 이동 변위를 계산합니다.
        let translation = self.translation(in: view)
        
        // 좌우 스와이프 동작을 인식하기 위한 기준을 설정합니다.
        let horizontalThreshold: CGFloat = 10.0
        
        // 이동 변위의 x값이 기준 값보다 크면 좌우 스와이프로 인식합니다.
        if translation.x > horizontalThreshold {
            // 오른쪽 스와이프 동작을 인식했음을 알립니다.
            state = .recognized
        } else if translation.x < -horizontalThreshold {
            // 왼쪽 스와이프 동작을 인식했음을 알립니다.
            state = .recognized
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        // 터치가 끝났을 때 인식 상태를 취소합니다.
        state = .cancelled
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        // 터치가 취소됐을 때 인식 상태를 취소합니다.
        state = .cancelled
    }
    
}
