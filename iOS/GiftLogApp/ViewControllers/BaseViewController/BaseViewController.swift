//
//  BaseViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        debugPrint("\(Date().debugDescription) _ Log: _ \(#function) in \(self)")
    }
    
    // MARK: Custom methods
    
    func addSearchNavigationBarButton() {
        let searchBarItem = UIBarButtonItem(image: UIImage(named: "search"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.searchBarButtonItemTapped))
        self.navigationItem.rightBarButtonItems = [searchBarItem]
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func addTapGestureRecognizerForKeyboardDissmiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Actions
    
    func searchBarButtonItemTapped() {
        NavigationManager.shared.showSearchViewControllerFromController(self)
    }
}
