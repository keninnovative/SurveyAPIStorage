//
//  WebViewViewController.swift
//  TapResearchTest
//
//  Created by Ken Nyame on 6/30/21.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    private let cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        addSubviews()
    }
    
    private func addSubviews() {
        addWebView()
        addCancelButton()
    }
    
    private func addWebView() {
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        webView.load(URLRequest(url: url))
    }
    
    private func addCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancelButton.addTarget(self, action: #selector(onDismiss(sender:)), for: .touchUpInside)
    }
    
    @objc func onDismiss(sender: UIButton) {
        self.dismiss(animated: true)
    }
}
