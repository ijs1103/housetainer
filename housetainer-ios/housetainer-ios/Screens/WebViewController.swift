//
//  WebViewController.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/29/24.
//

import WebKit
import UIKit
import SnapKit

final class WebViewController: UIViewController {
    
    private let webView = WKWebView()
    private var urlString: String? = nil
    
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.color = Color.purple400
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        setupWebView()
        setupViews()
        setupDelegates()
    }
}

extension WebViewController {
    private func setupWebView() {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        view = webView
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func setupViews() {
        webView.addSubview(spinner)
        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupDelegates() {
        webView.navigationDelegate = self
    }
}
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}
