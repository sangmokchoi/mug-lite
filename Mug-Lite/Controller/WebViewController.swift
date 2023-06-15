//
//  WebViewController.swift
//  Mug-Lite
//
//  Created by Sangmok Choi on 2023/06/14.
//

import UIKit
import WebKit
import YoutubePlayer_in_WKWebView

class WebViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userContentController: \(message.name)")
    }
    
    var query : String?
    var url : String?
    
    @IBOutlet weak var youtubeView: WKYTPlayerView!
    @IBOutlet var webViewGroup: UIView! // 배경 뷰
    private var webView: WKWebView! // 웹 뷰
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "#\(query)"
        // 뒤로가기 버튼 추가
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        backButton.tintColor = UIColor(named: "AccentTintColor")
        
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.backgroundColor = UIColor(named: "AccentColor")
        
        if !(url?.contains("youtube"))! {
            print("NO YOUTUBE")
            print("URL: \(url)")
            configure()
        } else {
            print("YES YOUTUBE")
            print("URL: \(url)")
            print("")
            let endIndex = url!.endIndex
            print("endIndex: \(endIndex)")
            let startIndex = url!.index(endIndex, offsetBy: -11)
            print("startIndex: \(startIndex)")
            let extractedString = String(url![startIndex..<endIndex])
            print("extractedString: \(extractedString)")
            youtubeViewConfigure(withVideoId: extractedString)
        }
        
    }
    
    @objc func goBack() {
        if let navigationController = navigationController {
            print("navigationController")
            //navigationController.popViewController(animated: true)
            navigationController.dismiss(animated: true)
        } else {
            print("dismiss")
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    private func youtubeViewConfigure(withVideoId: String) {
        youtubeView.alpha = 1.0
        youtubeView.load(withVideoId: withVideoId)
    }
    
    private func configure() {
        let webPageRreferences = WKWebpagePreferences()
        /** javaScript 사용 설정 */
        webPageRreferences.allowsContentJavaScript = true
        /** 자동으로 javaScript를 통해 새 창 열기 설정 */
        let preferences = WKPreferences() // 웹 뷰에 대한 기본 속성을 캡슐화한 클래스. 자바나 자바스크립 설정이 가능함
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = WKUserContentController()
        /** 사용할 메시지 등록 */
        contentController.add(self, name: "bridge")
        //javaScript에서 앱으로 메시지를 전달할 때는 add() 함수를 사용해 메시지의 이름을 설정한다.
        
        let configuration = WKWebViewConfiguration()
        /** preference, contentController 설정 */
        configuration.preferences = preferences
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        //WKWebViewConfiguration는 웹 뷰가 맨 처음 초기화될 때 호출되며, 웹 뷰가 생성된 이후에는 이 클래스를 통해 속성을 변경할 수 없다.
        
        // 웹 뷰 생성
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        var components = URLComponents(string: url!)!
        components.queryItems = [ URLQueryItem(name: "query", value: query ) ]
        
        let request = URLRequest(url: components.url!)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webViewGroup.addSubview(webView)
        setAutoLayout(from: webView, to: webViewGroup)
        webView.load(request)
        
        webView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.webView.alpha = 1
        }) { _ in
                    
        }
    }
    
    public func setAutoLayout(from: UIView, to: UIView) {
            
        from.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: from, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }

}

extension WebViewController {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        //print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
}
