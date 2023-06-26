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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }

    private func configure() {
        appleLoginButton.titleLabel?.adjustsFontSizeToFitWidth = false
        googleLoginButton.titleLabel?.adjustsFontSizeToFitWidth = false
        
        appleLoginButton?.layer.cornerRadius = 10
        appleLoginButton?.layer.borderWidth = 2
        appleLoginButton?.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        
        googleLoginButton?.layer.cornerRadius = 10
        googleLoginButton?.layer.borderWidth = 1
        googleLoginButton?.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        
        if traitCollection.userInterfaceStyle == .dark {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            //googleLoginButton.layer.borderColor = UIColor.white.cgColor

        } else {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            googleLoginButton.layer.borderColor = UIColor.black.cgColor
        }
        
    }

    @IBAction func appleLoginButtonPressed(_ sender: UIButton) {

        startSignInWithAppleFlow()
    }
    
    @IBAction func googleLoginButtonPressed(_ sender: UIButton) {

        googleSignIn()
    }
    
}
