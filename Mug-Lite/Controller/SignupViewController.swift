//
//  SignupViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import UIKit
import GoogleSignIn

class SignupViewController: UIViewController {

    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.configure()
        }
        
    }

    private func configure() {
        //appleLoginButton.titleLabel?.adjustsFontSizeToFitWidth = false
        //googleLoginButton.titleLabel?.adjustsFontSizeToFitWidth = false
        
        //appleLoginButton?.setImage(UIImage(named: "apple_logo"), for: .normal)
        //appleLoginButton?.setTitle(" Sign in with Apple", for: .normal)
        appleLoginButton?.layer.cornerRadius = 10
        appleLoginButton?.layer.borderWidth = 2
        //appleLoginButton?.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        googleLoginButton?.setImage(UIImage(named: "google_logo"), for: .normal)
        //googleLoginButton?.setTitle(" Sign in with Google", for: .normal)
        googleLoginButton?.layer.cornerRadius = 10
        googleLoginButton?.layer.borderWidth = 1
        //googleLoginButton?.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        if traitCollection.userInterfaceStyle == .dark {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            //googleLoginButton.layer.borderColor = UIColor.white.cgColor
            
        } else {
            //appleLoginButton.layer.borderColor = UIColor.white.cgColor
            googleLoginButton?.layer.borderColor = UIColor.black.cgColor
        }
        
    }
    
    @objc func stopLoadingView() {
        DispatchQueue.main.async {
            // Hide loading indicator
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
            
            // Enable user interaction
            self.view.isUserInteractionEnabled = true
        }
    }

    @IBAction func appleLoginButtonPressed(_ sender: UIButton) {

        startSignInWithAppleFlow()
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 50)
        ])

        loadingIndicator.startAnimating()
    }
    
    @IBAction func googleLoginButtonPressed(_ sender: UIButton) {

        googleSignIn()
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 50)
        ])

        loadingIndicator.startAnimating()
    }
    
}
