//
//  IAPService.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/07/14.
//

//public static let product5000 = "com.simonwork.MugLite.IAP.Point"
//public static let product10000 = "com.simonwork.MugLite.IAP.Point3000"

// 내부 델리게이트를 통해 IAP에 성공했는지 실패했는지 알 수 있고, 외부에도 completion을 제공하는 식으로 구현하기 위해서, 따로 Completion을 정의
//이 completion은 외부에서 정의하고, 실행은 내부에서 불리도록 구현 (delegate 패턴)

import StoreKit

typealias ProductsRequestCompletion = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol IAPServiceType {
    var canMakePayments: Bool { get }
    
    func getProducts(completion: @escaping ProductsRequestCompletion)
    func buyProduct(_ product: SKProduct)
    func isProductPurchased(_ productID: String) -> Bool
    func restorePurchases()
}

//외부에서 필요한 메소드를 명시하기 위해서 protocol 정의
//products 항목 가져오기 (getProducts)
//product 구입하기 (buyProduct)
//구입했는지 확인하기 (isProductPurchased)
//구입한 목록 조회 (restorePurchased)

final class IAPService: NSObject, IAPServiceType {
    private let productIDs: Set<String>
    private var purchasedProductIDs: Set<String> = []
    private var productsRequest: SKProductsRequest?
    private var productsCompletion: ProductsRequestCompletion?
    var purchased = [SKPaymentTransaction]();
    //StoreKit을 사용하려면 NSObject를 상속받고 IAPServiceType을 준수
    //추가로 필요한 프로퍼티 선언
    //productIDs: 앱스토어에서 입력한 productID들 "com.jake.sample.ExInAppPurchase.shopping"
    //purchasedProductIDs: 구매한 productID
    //productsRequest: 앱스토어에 입력한 productID로 부가 정보 조회할때 사용하는 인스턴스
    //proeductsCompletion: 사용하는쪽에서 해당 클로저를 통해 실패 or 성공했을때 값을 넘겨줄 수 있는 프로퍼티 (델리게이트)
    
    var canMakePayments: Bool {
        print("canMakePayments 진입")
        return SKPaymentQueue.canMakePayments()
    }
    //canMakePayments - queue를 확인하여 현재 결제가 되는지 확인
    
    init(productIDs: Set<String>) {
        self.productIDs = productIDs
        self.purchasedProductIDs = productIDs
            .filter { UserDefaults.standard.bool(forKey: $0) == true } // 구매 여부를 UserDefaults에 저장해두고 IAPService에서 ProductIDs를 받아올 때 초기화하여 사용
        
        super.init()
        SKPaymentQueue.default().add(self) // IAPService에 SKPaymentQueue를 연결
        print("IAPService에 SKPaymentQueue를 연결")
    }
    //상품 정보를 받아서 초기화
    //앱스토어에서 입력한 productID들 "com.jake.sample.ExInAppPurchase.shopping"
    func getProducts(completion: @escaping ProductsRequestCompletion) {
        print("getProducts 진입")
        self.productsRequest?.cancel()
        self.productsCompletion = completion
        print("self.productIDs : \(self.productIDs)")
        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIDs)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    func buyProduct(_ product: SKProduct) {
        print("buyProduct 진입")
        SKPaymentQueue.default().add(SKPayment(product: product))
        print("SKPayment(product: product): \(SKPayment(product: product))")
    }
    
    func isProductPurchased(_ productID: String) -> Bool {
        print("isProductPurchased 진입")
        return self.purchasedProductIDs.contains(productID)
    }
    
    func restorePurchases() {
        print("restorePurchases 진입")
        for productID in productIDs {
            UserDefaults.standard.set(false, forKey: productID)
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension IAPService: SKProductsRequestDelegate { // SKPaymentQueue에서 처리되는 일들
    // didReceive
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("productsRequest 진입")
        restorePurchases() // 처음에 PayVC에 들어올때 불러들이는 부분이므로 작동되지 않을까 기대
        let products = response.products
        self.productsCompletion?(true, products)
        self.clearRequestAndHandler()
        
        products.forEach { print("Found product: \($0.productIdentifier), \($0.localizedTitle), \($0.price.floatValue)") }
    }
    
    // failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("request 진입")
        print("Erorr: \(error.localizedDescription)")
        self.productsCompletion?(false, nil)
        self.clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        print("clearRequestAndHandler 진입")
        self.productsRequest = nil
        self.productsCompletion = nil
    }
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue 진입")
        print("transactions: \(transactions)")
        print("transactions.count: \(transactions.count)")
        print("")
        transactions.forEach {
            switch $0.transactionState {
            case .purchased:
                // 사용자에게 구매가 완료되었음을 알리고, 상품을 제공하거나 기타 후속 작업을 수행할 수 있습니다.
                print("completed transaction")
                self.deliverPurchaseNotificationFor(id: $0.payment.productIdentifier)
                
                deliverPurchase(for: $0)
                SKPaymentQueue.default().finishTransaction($0)
                NotificationCenter.default.post(name: Notification.Name("payVCloadingIsDone"), object: nil)
                // 거래가 성공, 실패, restore된 경우 finishTransaction을 실행
            case .failed:
                // 사용자에게 실패 메시지를 표시하거나 오류 처리를 수행할 수 있습니다.
                NotificationCenter.default.post(name: Notification.Name("payVCloadingIsDone"), object: nil)
                
                if let transactionError = $0.error as NSError?,
                   let description = $0.error?.localizedDescription,
                   transactionError.code != SKError.paymentCancelled.rawValue {
                    print("Transaction erorr: \(description)")
                    presentAlert(on: PayViewController(), withTitle: "Transaction erorr", message: "\(description)")

                }
                SKPaymentQueue.default().finishTransaction($0)
                break// 거래가 성공, 실패, restore된 경우 finishTransaction을 실행

            case .restored:
                // restore된 경우(구매 완료된 것 다시 조회) 구매했던 목록으로 추가 (UserDefaults)
                // 결제 검증을 했습니다.
                print("restored transaction")
                if let productsIdentifier = $0.original?.payment.productIdentifier {
                    // 구매한 인앱 상품 키에 대한 UserDefaults Bool 값 변경
                    purchasedProductIDs.insert(productsIdentifier)
                    print("restore: \(productsIdentifier)")
                    UserDefaults.standard.setValue(true, forKey: productsIdentifier)
                }
                
                SKPaymentQueue.default().finishTransaction($0)
                break // 거래가 성공, 실패, restore된 경우 finishTransaction을 실행
            case .deferred:
                // 결제 창을 띄우는데 실패했습니다
                print("deferred")
                DispatchQueue.main.async {
                    loadingViewLabelText = "지연되고 있습니다. 잠시만 기다려주세요"
                }
                SKPaymentQueue.default().finishTransaction($0)
                break
            case .purchasing:
                print("purchasing")
                DispatchQueue.main.async {
                    loadingViewLabelText = "진행 중입니다. 잠시만 기다려주세요"
                }
                NotificationCenter.default.post(name: Notification.Name("payVCloadingIsStart"), object: nil)
                // 사용자에게 로딩 인디케이터 등을 표시하여 진행 중임을 보여줄 수 있습니다.
            default:
                print("unknown")
            }
        }
    }
    
    private func deliverPurchaseNotificationFor(id: String?) {
        
        print("deliverPurchaseNotificationFor 진입")

        if let id = id {
            
            self.purchasedProductIDs.insert(id)
            print("purchasedProductIDs: \(self.purchasedProductIDs)")
            
            UserDefaults.standard.set(true, forKey: id)
            // 성공 노티 전송
            NotificationCenter.default.post(
                name: .iapServicePurchaseNotification,
                object: id
            )
            
            DispatchQueue.main.async {
                // 예시: 구매 내역을 알리는 알림창을 표시합니다.
                self.presentAlert(on: PayViewController(), withTitle: "구매 완료", message: "상품 \(id)를 구매했습니다")
            }
        } else { // 실패 노티 전송
            NotificationCenter.default.post( // <- 추가
                name: .iapServicePurchaseNotification,
                object: ""
            )
        }
    }
    
    func getReceiptData() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                return receiptString
            }
            catch {
                print("Couldn`t read receipt data with error: " + error.localizedDescription)
                return nil
            }
        }
        return nil
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError 발생")
        print("restoreCompletedTransactionsFailedWithError : \(error)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished 진입")
    }
    
}

extension IAPService {
    func presentAlert(on viewController: UIViewController, withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(action1)
        viewController.present(alertController, animated: true)
    }
    
    func deliverPurchase(for transaction: SKPaymentTransaction) {
        print("deliverPurchase 진입")
        
        if !purchased.contains(transaction) {
            
            purchased.append(transaction)
            
            //SKPaymentQueue.default().restoreCompletedTransactions()
            
            let productIdentifier = transaction.payment.productIdentifier
            
            switch productIdentifier {
            case MyProducts.productID1:
                print("com.simonwork.MugLite.IAP.Point") // 1500원 구매, 5000 포인트 충전 필요
                self.pointUpdate(newUserPoint: 5000) {
                    print("1500원 구매, 5000 포인트 충전 필요")
                    print("")
                }
                break
            case MyProducts.productID2:
                print("com.simonwork.MugLite.IAP.Point3000") // 3000원 구매, 10000 포인트 충전 필요
                self.pointUpdate(newUserPoint: 10000) {
                    print("3000원 구매, 10000 포인트 충전 필요")
                    print("")
                }
                
                break
            default:
                print("default")
            }
        } else {
            print("purchased.contains(transaction) 한 상태이므로, 이미 포인트가 적립된 상태")
        }
        
    }
}
