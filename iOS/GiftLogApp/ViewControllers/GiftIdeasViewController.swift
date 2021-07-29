//
//  GiftIdeasViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/13/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class GiftIdeasViewController: BaseRevealViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bottomNavigationBar: BottomNavigationBar!
    
    // MARK: Variables
    
    var menuButton: UIBarButtonItem!
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Gift Ideas"
        self.webView.backgroundColor = Constants.appGreyColor
        SSHelperManager.shared.setEmptyBackNavigationButtonIn(self)
        bottomNavigationBar.setButtonsFromController(self)
        addSearchNavigationBarButton()
        loadWebView()
    }
    
    //MARK: - Functions
    
    override func getMenuButton() -> UIBarButtonItem! {
        if menuButton == nil {
            setMenuButton()
        }
        return menuButton
    }

    func loadWebView() {
        HUDManager.showLoadingHUD()
        webView.loadRequest(URLRequest(url: URL(string: "https://www.giftlog.co.uk/giftideas/")!))
    }
    
    func setMenuButton() {
        menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
    }
}

extension GiftIdeasViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        HUDManager.hideLoadingHUDWithAnimation()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        HUDManager.showErrorHUD()
        debugPrint(error.localizedDescription)
    }
}

