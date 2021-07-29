//
//  TutorialViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/12/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    // MARK: Constraints
    
    @IBOutlet weak var scrollViewContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstScreenWidthConstraint: NSLayoutConstraint!
    
    // MARK: Views
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundContainerView: UIView!
    
    @IBOutlet weak var tutorialImageView1: UIImageView!
    @IBOutlet weak var tutorialImageView2: UIImageView!
    @IBOutlet weak var tutorialImageView3: UIImageView!
    @IBOutlet weak var tutorialImageView4: UIImageView!
    @IBOutlet weak var tutorialImageView5: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alwaysBounceHorizontal = false
        scrollView.bounces = false
        configureBottomButtons()
        firstScreenWidthConstraint.constant = UIScreen.main.bounds.width
        scrollViewContainerWidthConstraint.constant = UIScreen.main.bounds.width * 5
        if DeviceType.IS_IPAD {
            setImagesForIPad()
        }
    }
    
    func setImagesForIPad() {
        tutorialImageView1.image = UIImage(named: "ipad_1")
        tutorialImageView2.image = UIImage(named: "ipad_2")
        tutorialImageView3.image = UIImage(named: "ipad_3")
        tutorialImageView4.image = UIImage(named: "ipad_4")
        tutorialImageView5.image = UIImage(named: "ipad_5")
    }
    
    func configureBottomButtons() {
        self.view.bringSubview(toFront: pageControl)
        self.view.bringSubview(toFront: skipButton)
    }
    
    func notificationAccessWasChosen() {
        pageControl.currentPage = 5
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func dismissViewController() {
        UserDefaultsManager.shared.isTutorialScreenShowedBefore = true
        NavigationManager.shared.showLoginViewController()
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        dismissViewController()
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        dismissViewController()
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}

