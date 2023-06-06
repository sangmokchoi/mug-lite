//
//  SignupViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    private func configure() {
        
        appleLoginButton.layer.cornerRadius = 10
        appleLoginButton.layer.borderWidth = 2
        
        googleLoginButton.layer.cornerRadius = 10
        googleLoginButton.layer.borderWidth = 1
        
        if traitCollection.userInterfaceStyle == .dark {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            googleLoginButton.layer.borderColor = UIColor.white.cgColor
        } else {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            googleLoginButton.layer.borderColor = UIColor.black.cgColor
        }
        
    }

}
