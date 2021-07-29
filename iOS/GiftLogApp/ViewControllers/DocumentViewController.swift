//
//  DocumentViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class DocumentViewController: BaseViewController {

    // MARK: Enums
    
    enum Mode {
        case privacyPolicy
        case terms
        case contactUs
        case faq
    }
    
    // MARK: Views
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Vars
    
    internal var mode: Mode!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUDManager.showLoadingHUD()
        self.webView.backgroundColor = Constants.appGreyColor
        if mode == Mode.privacyPolicy {
            self.navigationItem.title = "Privacy Policy"
            if let url = URL(string: "https://www.giftlog.co.uk/privacy") {
                webView.loadRequest(URLRequest(url: url))
            }
        } else if mode == Mode.terms {
            self.navigationItem.title = "Terms & Conditions"
            if let url = URL(string: "https://www.giftlog.co.uk/terms") {
                webView.loadRequest(URLRequest(url: url))
            }
        } else if mode == Mode.contactUs {
            self.navigationItem.title = "Contact Us"
            if let url = URL(string: "https://www.giftlog.co.uk/contact/") {
                webView.loadRequest(URLRequest(url: url))
            }
        } else if mode == Mode.faq {
            self.navigationItem.title = "FAQ"
            if let url = URL(string: "https://www.giftlog.co.uk/faq/") {
                webView.loadRequest(URLRequest(url: url))
            }
        }
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonTapped))
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DocumentViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        HUDManager.hideLoadingHUDWithAnimation()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        HUDManager.showErrorHUD()
        debugPrint(error.localizedDescription)
    }
}

