//
//  SignupViewController.swift
//  KeepGoingNews
//
//  Created by Sangmok Choi on 2023/05/02.
//

import UIKit
import GoogleSignIn
import SafariServices

class SignupViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextViewDelegate {

    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var policyGuideTextView: UITextView!
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = .black
        containerView.alpha = 0.4
        return containerView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        return textView
    }()
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoadingView), name: NSNotification.Name(rawValue: "loadingIsDone"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.configure()
            self.textViewConfigure()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("signupVC viewDidDisappear 진입")
        NotificationCenter.default.post(name: Notification.Name("loadTrendingNews"), object: nil)
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
    
    func newUserCheck() -> Bool {
        var newUser : Bool?
        
        view.addSubview(containerView)
        
        if newUser == true {
            return true
        } else {
            return false
        }


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
    
    func textViewConfigure() {
        print("textViewConfigure 진입")
        let textViewHeight: CGFloat = 80 // textView의 높이 값
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let textViewWidth: CGFloat = 250 //view.bounds.width
        let bottomMargin: CGFloat = 20 // 원하는 최하단 여백 값
        let yPosition = screenHeight - textViewHeight - bottomMargin
        
        // 중앙 정렬 설정
        //textView.backgroundColor = .clear
        //textView.frame = CGRect(x: (screenWidth - textViewWidth) / 2, y: yPosition, width: textViewWidth, height: textViewHeight)

        //textView.center.x = view.center.x
        policyGuideTextView.textColor = UIColor(named: "AccentTintColor")
        //policyGuideTextView.textContainer.maximumNumberOfLines = 0

        let attributedString = NSMutableAttributedString(string: "계정 생성시 개인정보 처리방침 및 서비스 이용약관에 동의하게 됩니다")

        // 클릭 가능한 버튼의 속성 설정
        let buttonRange1 = (attributedString.string as NSString).range(of: "개인정보 처리방침")
        let buttonRange2 = (attributedString.string as NSString).range(of: "서비스 이용약관")
        
        let buttonAttributes1: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://sites.google.com/view/mug-lite-privacy-policy/%ED%99%88")!, // 버튼 클릭 시 호출되는 URL 설정
            .backgroundColor: UIColor.clear,
            //.foregroundColor: UIColor(named: "AccentTintColor"),
            //.strokeColor: UIColor.systemBlue,
            //.underlineStyle: NSUnderlineStyle.thick // 버튼의 밑줄 스타일 설정
        ]
        let buttonAttributes2: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://sites.google.com/view/mug-lite-policy/%ED%99%88")!, // 버튼 클릭 시 호출되는 URL 설정
            .backgroundColor: UIColor.clear,
            //.foregroundColor: UIColor(named: "AccentTintColor"),
            //.strikethroughColor: UIColor.systemBlue,
            //.underlineStyle: NSUnderlineStyle.thick // 버튼의 밑줄 스타일 설정
        ]
        attributedString.addAttributes(buttonAttributes1, range: buttonRange1)
        attributedString.addAttributes(buttonAttributes2, range: buttonRange2)

        policyGuideTextView.attributedText = attributedString

        // UITextView의 delegate를 설정하여 버튼 클릭 이벤트를 처리합니다.
        policyGuideTextView.delegate = self
        policyGuideTextView.textAlignment = .center
        
    }
    
}

extension UITextView {

    func centerText() {
        self.textAlignment = .center
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}
