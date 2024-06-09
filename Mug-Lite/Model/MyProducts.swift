//
//  MyProducts.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/07/14.
//

import Foundation

enum MyProducts {
    static let productID1 = "com.simonwork.MugLite.IAP.Point"
    static let productID2 = "com.simonwork.MugLite.IAP.Point3000"
    static let iapService: IAPServiceType = IAPService(productIDs: Set<String>([productID1, productID2]))
    
    static func getResourceProductName(_ id: String) -> String? {
        id.components(separatedBy: ".").last
    }
}
