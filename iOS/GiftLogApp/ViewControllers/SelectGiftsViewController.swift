//
//  SelectGiftsViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 5/1/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

protocol SelectGiftsViewControllerDelegate: class {
    func selectGiftsViewControllerDismissedWith(_ gifts: [Gift])
}

class SelectGiftsViewController: BaseViewController {
    
    // MARK: IBOutles
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var addView: UIView!
    
    // MARK: Variables
    
    internal var giftsAddedBefore: [Gift]! // gifts, that were already added to Event of Gift before
    fileprivate var giftsToDisplay = [Gift]() // gifts, that will be dispalayed to user after sort
    weak var delegate: SelectGiftsViewControllerDelegate?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDoneButton()
        setCancelButton()
        setTableView()
        setGifts()
        subscribeControllerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeControllerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setGifts), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserGiftsWereUpdated), object: nil)
    }
    
    func setGifts() {
        let giftsToFilter = UserGiftsManager.shared.userGifts
        giftsToDisplay.removeAll()
        for gift in giftsToFilter {
            if !UserGiftsManager.shared.isGiftAlreadyAdded(giftsAddedBefore, gift: gift) {
                giftsToDisplay.append(gift)
            }
        }
        tableView.reloadData()
    }
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        tableView.allowsSelection = false
    }
    
    func setDoneButton() {
        let doneBarItem = UIBarButtonItem(image: UIImage(named: "save"), style: .plain, target: self, action: #selector(self.doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneBarItem
    }
    
    func setCancelButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.cancelButtonTapped))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func giftsFromIndexPath(_ indexPath: IndexPath) -> Gift {
        return giftsToDisplay[indexPath.row]
    }
    
    
    // MARK: BarItem Actions
    
    func doneButtonTapped() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows, !selectedIndexPaths.isEmpty {
            var selectedGifts = [Gift]()
            for gift in giftsAddedBefore {
                selectedGifts.append(gift)
            }
            for indexPath in selectedIndexPaths {
                selectedGifts.append(self.giftsFromIndexPath(indexPath))
            }
            self.delegate?.selectGiftsViewControllerDismissedWith(selectedGifts)
            let _ = self.navigationController?.popViewController(animated: true)
        } else {
            UIAlertController.showAlertWithTitle("", message: "You didn't select any gift")
        }
    }
    
    func cancelButtonTapped() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: IBActions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        NavigationManager.shared.showGiftDetailViewControllerFrom(self, andWithMode: ControllerDetailPresentationMode.new)
    }
    
}

// MARK: Tableview DataSource and Delegate

extension SelectGiftsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // default
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultsLabel.isHidden = !giftsToDisplay.isEmpty
        return giftsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.setGiftContentFrom(giftsToDisplay[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.gray
        cell.tintColor = Constants.appGreenColor
        cell.shareButton.isHidden = true // force hide
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
    }
}
