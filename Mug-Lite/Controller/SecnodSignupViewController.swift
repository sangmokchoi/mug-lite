//
//  SecnodSignupViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/07/10.
//

import UIKit
import SafariServices

class SecnodSignupViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var servicePolicyCheckbox: UIButton!
    @IBOutlet weak var privacyPolicyCheckbox: UIButton!
    
    var isServicePolicyCheckboxClicked : Bool = false
    var isPrivacyPolicyCheckboxClicked : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.view.alpha = 0.4
        
        NSLayoutConstraint.activate([
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }

    @IBAction func servicePolicyButtonPressed(_ sender: UIButton) {

        print("이용방법")
        if let url = URL(string: "https://sites.google.com/view/howtouse-mug-lite/%ED%99%88") {
            let URL = url
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: URL, configuration: config)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet

            present(safariVC, animated: true, completion: nil)
            //UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
        print("개인정보 처리방침")
        if let url = URL(string: "https://sites.google.com/view/mug-lite-privacy-policy/%ED%99%88") {
            let URL = url
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: URL, configuration: config)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet

            present(safariVC, animated: true, completion: nil)
            //UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func servicePolicyCheckboxClicked(_ sender: UIButton) {
        if isServicePolicyCheckboxClicked == false {
            isServicePolicyCheckboxClicked = true
            servicePolicyCheckbox.setImage(UIImage(named: "checkmark"), for: .normal)
        } else {
            isServicePolicyCheckboxClicked = false
            servicePolicyCheckbox.setImage(UIImage(named: "square"), for: .normal)
        }
        
    }
    
    @IBAction func privacyPolicyCheckboxClicked(_ sender: UIButton) {
        
        if isPrivacyPolicyCheckboxClicked == false {
            isPrivacyPolicyCheckboxClicked = true
            privacyPolicyCheckbox.setImage(UIImage(named: "checkmark"), for: .normal)
        } else {
            isPrivacyPolicyCheckboxClicked = false
            privacyPolicyCheckbox.setImage(UIImage(named: "square"), for: .normal)
        }
    }
    
    @IBAction func keepProcessing(_ sender: UIButton) {
        // self.dismiss 이후에 유저가 클릭했던 로그인 방식을 이어야 해야함
        
    }
}
