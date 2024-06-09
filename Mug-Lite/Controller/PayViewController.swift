//
//  PayViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/07/04.
//

import Foundation
import UIKit
import StoreKit
import Firebase

var loadingViewLabelText = ""

class PayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var point5000PurchaseLabel: UILabel!
    @IBOutlet weak var point5000PurchaseButton: UIButton!
    @IBOutlet weak var point10000PurchaseLabel: UILabel!
    @IBOutlet weak var point10000PurchaseButton: UIButton!
    
    private var products = [SKProduct]()
    
    var purchasedPoint : [Int] = []
    var purchasedTime : [Date] = []
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    lazy var loadingView: UIView = {
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loadingView.backgroundColor = .black
        loadingView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

        return loadingView
    }()
    
    lazy var loadingViewLabel: UILabel = {
        let loadingViewLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        loadingViewLabel.font = .systemFont(ofSize: 15, weight: .light)
        loadingViewLabel.textColor = .white//UIColor(named: "AccentTintColor")
        loadingViewLabel.tintColor = .white
        loadingViewLabel.textAlignment = .center

        return loadingViewLabel
    }()
    
//    lazy var overlayView: UIView = {
//        let overlayView = UIView(frame: UIScreen.main.bounds)
//        overlayView.backgroundColor = UIColor.clear
//        overlayView.isUserInteractionEnabled = true
//        return overlayView
//    }()
    
    lazy var Xbutton: UIButton = {
        let Xbutton = UIButton(frame: CGRect(x: PurchasedtableView.bounds.width - 35, y: PurchasedtableView.bounds.minY, width: 35, height: 35))
        
        let XbuttonImage = UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysTemplate)
            
        Xbutton.setImage(XbuttonImage, for: .normal)
        //Xbutton.setTitle("x", for: .normal)
        Xbutton.tintColor = .white
        Xbutton.setTitleColor(.white, for: .normal)
        Xbutton.addTarget(self, action: #selector(XbuttonTapped(_:)), for: .touchUpInside)

        return Xbutton
    }()
    
    @objc func XbuttonTapped(_ sender: UIButton) {
        print("Button Tapped!")
        DispatchQueue.main.async {
            self.PurchasedtableView.removeFromSuperview()
            self.Xbutton.removeFromSuperview()
        }
    }
    
    lazy var PurchasedtableView: UITableView = {
        let PurchasedtableView = UITableView(frame:CGRect(
                x: (UIScreen.main.bounds.width - (UIScreen.main.bounds.width - 30)) / 2,
                y: 200,
                width: UIScreen.main.bounds.width - 30,
                height: UIScreen.main.bounds.height / 2 + 40))
        PurchasedtableView.backgroundColor = .darkGray
        PurchasedtableView.alpha = 1.0
        PurchasedtableView.bounces = false
        return PurchasedtableView
    }()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let placeholderLabel = UILabel(frame: CGRect(x: 0, y: point10000PurchaseButton.bounds.minY + 15, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        placeholderLabel.text = "구매내역이 없습니다"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .white
        
        if self.purchasedPoint.count == 0 {
            DispatchQueue.main.async {
                tableView.backgroundView = placeholderLabel
            }
        } else {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        }
        return self.purchasedPoint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Purchased Point: \(purchasedPoint[indexPath.row])"
        cell.textLabel?.textColor = UIColor.white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.detailTextLabel?.text = "Purchased Time: \(dateFormatter.string(from: purchasedTime[indexPath.row]))"
        cell.detailTextLabel?.textColor = UIColor.white
        
        cell.backgroundColor = UIColor.gray
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return print("indexPath.row: \(indexPath.row)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PurchasedtableView.delegate = self
        PurchasedtableView.dataSource = self
        
        PurchasedtableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        startLoadingView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "payVCloadingIsDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startLoadingView), name: NSNotification.Name(rawValue: "payVCloadingIsStart"), object: nil)
        
        print("PayViewController 진입")
        
        MyProducts.iapService.getProducts { [weak self] success, products in
            print("load products: \(products ?? [])")
            
            guard let ss = self else { return }
            if success, let products = products {
                DispatchQueue.main.async {
                    ss.products = products
                    // 여기가 완료된 다음에 버튼이 클릭되어야만 구매가 정상 작동함
                    NotificationCenter.default.post(name: Notification.Name("payVCloadingIsDone"), object: nil)
                }
            }
        }
        
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(handlePurchaseNoti(_:)),
              name: .iapServicePurchaseNotification,
              object: nil
            )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingIndicatorConfigure()
    }

    private func loadingIndicatorConfigure() {
        
        point5000PurchaseButton.layer.cornerRadius = 10
        point10000PurchaseButton.layer.cornerRadius = 10
        
        point5000PurchaseButton.layer.shadowColor = UIColor.black.cgColor
        point5000PurchaseButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        point5000PurchaseButton.layer.shadowRadius = 4
        point5000PurchaseButton.layer.shadowOpacity = 0.5
        point5000PurchaseButton.layer.masksToBounds = false
        
        point5000PurchaseLabel.layer.shadowColor = UIColor.black.cgColor
        point5000PurchaseLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        point5000PurchaseLabel.layer.shadowRadius = 1
        point5000PurchaseLabel.layer.shadowOpacity = 0.3
        point5000PurchaseLabel.layer.masksToBounds = false
        
        point10000PurchaseButton.layer.shadowColor = UIColor.black.cgColor
        point10000PurchaseButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        point10000PurchaseButton.layer.shadowRadius = 4
        point10000PurchaseButton.layer.shadowOpacity = 0.5
        point10000PurchaseButton.layer.masksToBounds = false
        
        point10000PurchaseLabel.layer.shadowColor = UIColor.black.cgColor
        point10000PurchaseLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        point10000PurchaseLabel.layer.shadowRadius = 1
        point10000PurchaseLabel.layer.shadowOpacity = 0.3
        point10000PurchaseLabel.layer.masksToBounds = false
    }
    
    @objc func startLoadingView() {
        DispatchQueue.main.async {
            self.loadingIndicator.color = UIColor(named: "Main Color")
            
            self.loadingView.addSubview(self.loadingIndicator)
            self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.loadingIndicator.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
                self.loadingIndicator.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor)
            ])
            print("loadingViewLabelText: \(loadingViewLabelText)")
            
            self.loadingViewLabel.text = loadingViewLabelText
            
            self.loadingView.addSubview(self.loadingViewLabel)
            self.view.bringSubviewToFront(self.loadingViewLabel)
            self.loadingViewLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.loadingViewLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
                self.loadingViewLabel.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor, constant: -50),
                self.loadingViewLabel.widthAnchor.constraint(equalToConstant: 250),
                self.loadingViewLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            self.loadingIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.view.addSubview(self.loadingView)
        }
        
    }

    @objc func stopLoadingView() {
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
            self.loadingViewLabel.removeFromSuperview()
            
            loadingViewLabelText = "결제 준비 중입니다"
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
            self.loadingView.removeFromSuperview()
        }
    }
    
    @objc private func handlePurchaseNoti(_ notification: Notification) {
        print("handlePurchaseNoti 진입")
        print("notification : \(notification)")
      guard
        let productID = notification.object as? String,
        let index = self.products.firstIndex(where: { $0.productIdentifier == productID })
      else { return }
        print("handlePurchaseNoti productID: \(productID)")
        print("handlePurchaseNoti index: \(index)")
        
        let date = DateFormatter()
            date.locale = Locale(identifier: Locale.current.identifier)
            date.timeZone = TimeZone(identifier: TimeZone.current.identifier)
            date.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = date.string(from: Date())
        print("dateString: \(dateString)")
        let trueDate = date.date(from: dateString)
        
        if productID == "com.simonwork.MugLite.IAP.Point3000" {
            print("productID == com.simonwork.MugLite.IAP.Point3000")
            uploadPurchased(trueDate!, 10000) {
                
            }
            alert1(title: "구매완료", message: "10000 포인트 충전되었습니다", actionTitle1: "확인")
            // 서버에 구매 이력 등록 필요
        } else if productID == "com.simonwork.MugLite.IAP.Point" {
            print("productID == com.simonwork.MugLite.IAP.Point")
            uploadPurchased(trueDate!, 5000) {
                
            }
            alert1(title: "구매완료", message: "5000 포인트 충전되었습니다", actionTitle1: "확인")
            // 서버에 구매 이력 등록 필요
        } else {
            alert1(title: "잠시만요", message: "구매 중 오류가 발생했습니다. 다시 시도해주세요", actionTitle1: "확인")
        }
    }
    
    @objc private func restore() {
        MyProducts.iapService.restorePurchases()
    }
    
    @IBAction func point5000PurchaseButtonPressed(_ sender: UIButton) {
        print("PayVC products: \(products)")
        if let productsFirst = products.first {
            MyProducts.iapService.buyProduct(productsFirst)
        } else {
            alert1(title: "잠시만요", message: "오류가 발생했습니다. 잠시후 다시 시도해주세요", actionTitle1: "확인")
        }
    
    }
    
    @IBAction func point10000PurchaseButtonPressed(_ sender: UIButton) {
        print("PayVC products: \(products)")
        if let productsLast = products.last {
            MyProducts.iapService.buyProduct(productsLast)
        } else {
            alert1(title: "잠시만요", message: "오류가 발생했습니다. 잠시후 다시 시도해주세요", actionTitle1: "확인")
        }
    }

    @IBAction func restorePurchasesButtonPressed(_ sender: UIButton) {
        //MyProducts.iapService.restorePurchases()
        //self.PurchasedtableView.reloadData()
        purchasedPoint = []
        purchasedTime = []

        loadPurchased {
            print("loadPurchased 종료")
            DispatchQueue.main.async {
                self.view.addSubview(self.Xbutton)
                self.PurchasedtableView.addSubview(self.Xbutton)
                
                
                //self.view.addSubview(self.overlayView)
                //self.view.bringSubviewToFront(self.overlayView)
                
                self.view.addSubview(self.PurchasedtableView)
                self.view.bringSubviewToFront(self.PurchasedtableView)
                //self.view.bringSubviewToFront(self.Xbutton)
                
                self.PurchasedtableView.reloadData()
                
            }
        }
    }
}

extension PayViewController {
    
    func loadPurchased(completion: @escaping() -> Void) {
        // 포인트 사용시에는 newUserPoint로 입력되어야 함
        
        if let userUid = UserDefaults.standard.string(forKey: "uid"),
           let userFriendCode = UserDefaults.standard.string(forKey: "friendCode") {
            db.collection("Purchased").whereField("friendCode", isEqualTo: userFriendCode).whereField("uid", isEqualTo: userUid).order(by: "PurchasedTime", descending: true).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            let data = document.data()
                            let Purchased_Time = data["PurchasedTime"] as! Timestamp
                            let PurchasedTime = Purchased_Time.dateValue()
                            let PurchasedPoint = data["PurchasedPoint"] as! Int
                            
                            self.purchasedTime.append(PurchasedTime)
                            self.purchasedPoint.append(PurchasedPoint)
                        }
                        print("self.purchasedTime: \(self.purchasedTime)")
                        print("self.purchasedPoint: \(self.purchasedPoint)")
                        DispatchQueue.main.async {
                            self.PurchasedtableView.reloadData()
                        }
                    }
                }
            }
        } else {
            print("userUid 없음")
        }
        completion()
    }
    
    func uploadPurchased(_ PurchasedTime: Date, _ PurchasedPoint: Int, completion: @escaping() -> Void) {
        
        if let userUid = UserDefaults.standard.string(forKey: "uid"),
            let userFriendCode = UserDefaults.standard.string(forKey: "friendCode") {

            // 문서를 하나씩 생성 (친구코드로 필터링해서 구매내역 추출하면 될듯)
            db.collection("Purchased").addDocument(data: [
                "uid" : userUid,
                "friendCode" : userFriendCode,
                "PurchasedPoint": PurchasedPoint,
                "PurchasedTime": PurchasedTime
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Purchased upload Done")
                }
                completion()
            }
        } else {
            print("userUid, friendCode 없음")
        }
    }
    
}
