//
//  BottomNavigationBar.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/4/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

class BottomNavigationBar: UIView {

    // MARK: Vars
    
    let buttonSizeConstant: CGFloat = 30.0
    let buttonWidth: CGFloat = 90.0
    let viewCenterY: CGFloat = 64.0 / 2.0
    
    weak var controller: UIViewController!
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }
    
    private func setView() {
    }
    
    func getLabelWithTitle(_ title: String) ->  UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20.0))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.adjustsFontSizeToFitWidth = true
        label.text = title
        return label
    }
    
    func getGiftsButton() -> UIButton {
        let button = UIButton.init(type: UIButtonType.system)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 2*buttonSizeConstant)
        button.setImage(UIImage(named: "gift"), for: UIControlState.normal)
        button.setImage(UIImage(named: "gift"), for: UIControlState.highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: buttonSizeConstant, right: 5)
        button.addTarget(self, action: #selector(self.giftsButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func getEventsButton() -> UIButton {
        let button = UIButton.init(type: UIButtonType.system)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 2*buttonSizeConstant)
        button.setImage(UIImage(named: "calendar"), for: UIControlState.normal)
        button.setImage(UIImage(named: "calendar"), for: UIControlState.highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: buttonSizeConstant, right: 5)
        button.addTarget(self, action: #selector(self.eventsButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func getGiftIdeasButton() -> UIButton {
        let button = UIButton.init(type: UIButtonType.system)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 2*buttonSizeConstant)
        button.setImage(UIImage(named: "idea"), for: UIControlState.normal)
        button.setImage(UIImage(named: "idea"), for: UIControlState.highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: buttonSizeConstant, right: 5)
        button.addTarget(self, action: #selector(self.giftIdeasButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func getContactsButton() -> UIButton {
        let button = UIButton.init(type: UIButtonType.system)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 2*buttonSizeConstant)
        button.setImage(UIImage(named: "contact"), for: UIControlState.normal)
        button.setImage(UIImage(named: "contact"), for: UIControlState.highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: buttonSizeConstant, right: 5)
        button.addTarget(self, action: #selector(self.contactButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func setButtonsFromController(_ controller: UIViewController) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.controller = controller
        var firstButton: UIButton!
        var secondButton: UIButton!
        var thirdButton: UIButton!
        var firstLabel: UILabel!
        var secondLabel: UILabel!
        var thirdLabel: UILabel!
        
        if controller is GiftsViewController {
            firstButton = getEventsButton()
            secondButton = getContactsButton()
            thirdButton = getGiftIdeasButton()
            firstLabel = getLabelWithTitle("EVENTS")
            secondLabel = getLabelWithTitle("CONTACTS")
            thirdLabel = getLabelWithTitle("GIFT IDEAS")
        } else if controller is EventsViewController {
            firstButton = getGiftsButton()
            secondButton = getContactsButton()
            thirdButton = getGiftIdeasButton()
            firstLabel = getLabelWithTitle("GIFTS")
            secondLabel = getLabelWithTitle("CONTACTS")
            thirdLabel = getLabelWithTitle("GIFT IDEAS")
        } else if controller is ContactsViewController {
            firstButton = getGiftsButton()
            secondButton = getEventsButton()
            thirdButton = getGiftIdeasButton()
            firstLabel = getLabelWithTitle("GIFTS")
            secondLabel = getLabelWithTitle("EVENTS")
            thirdLabel = getLabelWithTitle("GIFT IDEAS")
        } else if controller is GiftIdeasViewController {
            firstButton = getGiftsButton()
            secondButton = getEventsButton()
            thirdButton = getContactsButton()
            firstLabel = getLabelWithTitle("GIFTS")
            secondLabel = getLabelWithTitle("EVENTS")
            thirdLabel = getLabelWithTitle("CONTACTS")
        }
        
        self.addSubview(firstButton)
        firstButton.center = CGPoint(x: ((UIScreen.main.bounds.width / 2) / 2) - 20.0, y: viewCenterY)
        self.addSubview(firstLabel)
        firstLabel.center = CGPoint(x: ((UIScreen.main.bounds.width / 2) / 2) - 20.0, y: viewCenterY + 20.0)
        
        self.addSubview(secondButton)
        secondButton.center = CGPoint(x: (UIScreen.main.bounds.width / 2), y: viewCenterY)
        self.addSubview(secondLabel)
        secondLabel.center = CGPoint(x: (UIScreen.main.bounds.width / 2), y: viewCenterY + 20.0)
        
        self.addSubview(thirdButton)
        thirdButton.center = CGPoint(x: ((UIScreen.main.bounds.width/2) / 2) + (UIScreen.main.bounds.width/2) + 20.0, y: viewCenterY)
        self.addSubview(thirdLabel)
        thirdLabel.center = CGPoint(x: ((UIScreen.main.bounds.width/2) / 2) + (UIScreen.main.bounds.width/2) + 20.0, y: viewCenterY + 20.0)
    }
    
    // MARK: Buttons Actions
    
    func giftsButtonTapped() {
        NavigationManager.shared.showMenuFrontViewControllerFromController(controller, menuAction: MenuAction.openGifts)
    }
    
    func eventsButtonTapped() {
        NavigationManager.shared.showMenuFrontViewControllerFromController(controller, menuAction: MenuAction.openEvents)
    }
    
    func giftIdeasButtonTapped() {
        NavigationManager.shared.showMenuFrontViewControllerFromController(controller, menuAction: MenuAction.openGiftIdeas)
    }
    
    func contactButtonTapped() {
        NavigationManager.shared.showMenuFrontViewControllerFromController(controller, menuAction: MenuAction.openContacts)
    }
}
