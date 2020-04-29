//
//  ViewController.swift
//  Project4
//
//  Created by Roman Cebula on 29/03/2020.
//  Copyright © 2020 Roman Cebula. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
  
  private var webView: WKWebView!
  private var progressView: UIProgressView!
  private var websites = ["apple.com", "hackingwithswift.com", "google.com", "youtube.com", "linkedin.com", "twitter.com"]
  
  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
    let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
    let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
    progressView = UIProgressView(progressViewStyle: .default)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    toolbarItems = [back,forward,progressButton,spacer,refresh]
    navigationController?.isToolbarHidden = false
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    let url = URL(string: "https://" + websites[0])!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
  }

  @objc private func openTapped(){
    let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
    for website in websites {
      ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
    }
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
    present(ac, animated: true)
  }
  func openPage(action: UIAlertAction){
    guard let actionTitle = action.title else { return }
    guard let url = URL(string: "https://" + actionTitle) else { return }
    webView.load(URLRequest(url: url))
  }
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    let url = navigationAction.request.url
    if let host = url?.host {
      for website in websites {
        if host.contains(website){
          decisionHandler(.allow)
          return
        }
      }
    }
    decisionHandler(.cancel)
    let notAllowedURL = UIAlertController(title: "This url cannot be opened.", message: "This url is not specified in app list.", preferredStyle: .alert)
    notAllowedURL.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(notAllowedURL, animated: true)
  }
}

extension ViewController: WKNavigationDelegate {
  
}

