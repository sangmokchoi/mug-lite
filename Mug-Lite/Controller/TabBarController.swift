//
//  TabBarController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/05.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor(hex: "98DFF2") 
        self.tabBar.unselectedItemTintColor = .gray

        // 탭 바 아이템의 tag 속성 설정
        self.tabBar.items?[0].tag = 0
        self.tabBar.items?[1].tag = 1
        self.tabBar.items?[2].tag = 2
        self.tabBar.items?[3].tag = 3

        self.delegate = self
    }

}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 선택된 아이템의 인덱스 확인
        if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) {
            if selectedIndex == 0 {
                print("selectedIndex: \(selectedIndex)")
            } else if selectedIndex == 1 {
                print("selectedIndex: \(selectedIndex)")
            } else if selectedIndex == 2 {
                print("selectedIndex: \(selectedIndex)")
            } else {
                print("selectedIndex: \(selectedIndex)")
            }

        }
    }
}


extension UIColor {
    convenience init?(hex: String) {
        //let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        let red, green, blue: CGFloat
        switch hex.count {
        case 6:
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        default:
            return nil
        }
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
