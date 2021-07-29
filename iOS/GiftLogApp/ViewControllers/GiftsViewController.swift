//
//  GiftsViewController.swift
//  GiftLogApp
//
//  Created by Webs The Word on 3/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit
import HMSegmentedControl
import MGSwipeTableCell

class GiftsViewController: BaseRevealViewController {
    
    enum SortingType: String {
        case alphabet = " A to Z"
        case oppositeAlphabet = " Z to A"
    }
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: HMSegmentedControl!
    @IBOutlet weak var sortButtonImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var bottomNavigationBar: BottomNavigationBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    
    //MARK: - Constants
    
    let sortRegularTitle = "Sort by"
    let filterRegularTitle = "Filter by"
    
    //MARK: - Variables
    
    var menuButton: UIBarButtonItem!
    var sortedGiftsArray: [Gift] = []
    var sortedIndex: Int?
    var filteredIndex: Int?
    var giftTypeIndex: Int?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Gifts"
        SSHelperManager.shared.setEmptyBackNavigationButtonIn(self)
        setCustomSegmentedControl()
        bottomNavigationBar.setButtonsFromController(self)
        addSearchNavigationBarButton()
        setSortLabel("", with: sortRegularTitle)
        setTableView()
        
        // handle local notifications at this screen, as Gifts are first screen in menu.
        if let localNotification = RemindService.shared.unhandledLocalNotification {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AppDelegate.handleLocalNotification(localNotification, from: UIApplication.shared, ignoringAppState: true)
                RemindService.shared.unhandledLocalNotification = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataInController), name: NSNotification.Name(rawValue: NotificationCenterManager.NotificationNames.UserGiftsWereUpdated), object: nil)
        self.reloadDataInController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Functions
    
    override func getMenuButton() -> UIBarButtonItem! {
        if menuButton == nil {
            setMenuButton()
        }
        return menuButton
    }
    
    func setSortedGiftsArray() { // Uses to sort all gifts. Depends on segmented value.
        sortedGiftsArray = UserGiftsManager.shared.userGifts
        if filteredIndex != nil {
            giftFiltering(filteredIndex!)
        }
        if giftTypeIndex != nil {
            giftTypeSorting(giftTypeIndex!)
        }
        if sortedIndex != nil {
            giftAlphabetSorting(sortedIndex!)
        }
    }
    
    func setMenuButton() {
        menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func setCustomSegmentedControl() {
        segmentedControl.sectionTitles = ["ALL", "RECEIVED", "GIVEN"]
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.appGreenColor, NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)]
        segmentedControl.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleWidth]
        segmentedControl.selectionIndicatorHeight = 2.0
        segmentedControl.selectionIndicatorColor = Constants.appVioletColor
        segmentedControl.backgroundColor = Constants.appGreyColor
        segmentedControl.selectionIndicatorLocation = .down
        segmentedControl.selectionStyle = .fullWidthStripe
        segmentedControl.addTarget(self, action: #selector(self.segmentedControlChangedValue(_:)), for: .valueChanged)
    }
    
    func setSortLabel(_ string: String, with regular: String) {
        sortLabel.attributedText = SSHelperManager.shared.getBoldAttributedStringFromString(regular, stringToMakeBold: string, color: .lightGray, fontSize: 12.0)
    }
    
    func setFilterLabel(_ string: String, with regular: String) {
        filterLabel.attributedText = SSHelperManager.shared.getBoldAttributedStringFromString(regular, stringToMakeBold: string, color: .lightGray, fontSize: 12.0)
    }
    
    func setTableView() {
        tableView.tableFooterView = UIView.emptyView
        tableView.tableFooterView?.backgroundColor = Constants.appGreyColor
        tableView.register(UINib(nibName: UniversalTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: UniversalTableViewCellIdentifier)
    }
    
    func reloadDataInController() {
        giftTypeIndex = segmentedControl.selectedSegmentIndex
        self.setSortedGiftsArray()
    }
    
    func deleteGiftAtIndexPath(_ indexPath: IndexPath) {
        let gift = sortedGiftsArray[indexPath.row]
        HUDManager.showNetworkActivityIndicator()
        FirebaseManager.shared.deleteGiftFromDatabase(gift) { (success) in
            HUDManager.hideNetworkActivityIndicator()
        }
    }
    
    func copyGiftAtIndexPath(_ indexPath: IndexPath) {
        let gift = sortedGiftsArray[indexPath.row]
        let newGift = gift.copyGift()
        NavigationManager.shared.showGiftDetailViewControllerFrom(self, withGift: newGift, andWithMode: ControllerDetailPresentationMode.new)
    }
    
    func showGiftOptionActionSheet() {
        let actionSheetController = UIAlertController(title: "Sort", message: "Option to select", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        let alphabetSorting = UIAlertAction(title: SortingType.alphabet.rawValue, style: .default) { action -> Void in
            self.sortedIndex = 0
            self.setSortedGiftsArray()
        }
        actionSheetController.addAction(alphabetSorting)
        let oppositeAlphabetSorting = UIAlertAction(title: SortingType.oppositeAlphabet.rawValue, style: .default) { action -> Void in
            self.sortedIndex = 1
            self.setSortedGiftsArray()
        }
        actionSheetController.addAction(oppositeAlphabetSorting)
        let noneSorting = UIAlertAction(title: "None", style: .default) { action -> Void in
            self.sortedIndex = nil
            self.setSortedGiftsArray()
            self.setSortLabel("", with: self.sortRegularTitle)
        }
        actionSheetController.addAction(noneSorting)
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = sortButton
            popoverController.sourceRect = sortButton.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showGiftFilterActionSheet() {
        let actionSheetController = UIAlertController(title: "Filter", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        
        let keepSorting = UIAlertAction(title: Gift.Status.keep.description, style: .default) { action -> Void in
            self.filteredIndex = 0
            self.setSortedGiftsArray()
            self.setFilterLabel(" \(Gift.Status.allValuesWithDescription[self.filteredIndex!])", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(keepSorting)
        
        let regiftSorting = UIAlertAction(title: Gift.Status.regift.description, style: .default) { action -> Void in
            self.filteredIndex = 1
            self.setSortedGiftsArray()
            self.setFilterLabel(" \(Gift.Status.allValuesWithDescription[self.filteredIndex!])", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(regiftSorting)
        
        let returnSorting = UIAlertAction(title: Gift.Status.returned.description, style: .default) { action -> Void in
            self.filteredIndex = 2
            self.setSortedGiftsArray()
            self.setFilterLabel(" \(Gift.Status.allValuesWithDescription[self.filteredIndex!])", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(returnSorting)
        
        let exchangeSorting = UIAlertAction(title: Gift.Status.exchange.description, style: .default) { action -> Void in
            self.filteredIndex = 3
            self.setSortedGiftsArray()
            self.setFilterLabel(" \(Gift.Status.allValuesWithDescription[self.filteredIndex!])", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(exchangeSorting)
        
        let noneSorting = UIAlertAction(title: "None", style: .default) { action -> Void in
            self.filteredIndex = 4
            self.setSortedGiftsArray()
            self.setFilterLabel(" \(Gift.Status.allValuesWithDescription[self.filteredIndex!])", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(noneSorting)
        
        let clearSorting = UIAlertAction(title: "Clear filter", style: .default) { action -> Void in
            self.filteredIndex = nil
            self.setSortedGiftsArray()
            self.setFilterLabel("", with: self.filterRegularTitle)
        }
        actionSheetController.addAction(clearSorting)
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = filterButton
            popoverController.sourceRect = filterButton.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func giftTypeSorting(_ sortIndex: Int) {
        if sortIndex != 0 {
            var tempGiftArray: [Gift] = []
//            setSortedGiftsArray()
            for item in sortedGiftsArray {
                if item.inOutType == sortIndex - 1 {
                    tempGiftArray.append(item)
                }
            }
            sortedGiftsArray = tempGiftArray
        } else {
//            setSortedGiftsArray()
        }
        tableView.reloadData()
    }
    
    func giftFiltering(_ filterIndex: Int) {
        var tempGiftArray: [Gift] = []
//            setSortedGiftsArray()
        for item in sortedGiftsArray {
            if item.status == filterIndex {
                tempGiftArray.append(item)
            }
        }
        sortedGiftsArray = tempGiftArray
        self.filteredIndex = filterIndex
        tableView.reloadData()
    }
    
    func giftAlphabetSorting(_ sortIndex: Int) {
//        setSortedGiftsArray()
        if sortedIndex == 0 {
            self.sortedGiftsArray = self.sortedGiftsArray.sorted(by: { $0.name < $1.name })
            self.setSortLabel(SortingType.alphabet.rawValue, with: self.sortRegularTitle)
        } else {
            self.sortedGiftsArray = self.sortedGiftsArray.sorted(by: { $0.name > $1.name })
            self.setSortLabel(SortingType.oppositeAlphabet.rawValue, with: self.sortRegularTitle)
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Actions
    
    @IBAction func segmentedControlChangedValue(_ sender: HMSegmentedControl) {
        giftTypeIndex = segmentedControl.selectedSegmentIndex
        self.setSortedGiftsArray()
    }
    
    @IBAction func sortButtonDidTouch(_ sender: Any) {
        showGiftOptionActionSheet()
    }
    
    @IBAction func filterButtonDidTouch(_ sender: Any) {
        showGiftFilterActionSheet( )
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        NavigationManager.shared.showGiftDetailViewControllerFrom(self, andWithMode: ControllerDetailPresentationMode.new)
    }
}

// MARK: - TableView DataSource and Delegate

extension GiftsViewController: UITableViewDataSource ,UITableViewDelegate, MGSwipeTableCellDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noResultsLabel.isHidden = !sortedGiftsArray.isEmpty
        return sortedGiftsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCellIdentifier, for: indexPath) as! UniversalTableViewCell
        cell.delegate = self
        cell.setGiftContentFrom(sortedGiftsArray[indexPath.row])
        cell.rightButtons = [MGSwipeService.deleteButton(), MGSwipeService.copyButton()]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NavigationManager.shared.showGiftDetailViewControllerFrom(self, withGift: sortedGiftsArray[indexPath.row], andWithMode: ControllerDetailPresentationMode.old)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //FIXME: Delete method if unused
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let action = SwipeTableViewCellAction(rawValue: index)
        if action == .delete {
            if let indexPath = self.tableView.indexPath(for: cell) {
                AlertManager.shared.showDeleteAlertViewFrom(self, deleteButtonTitle: "Delete gift", completion: { [unowned self] (buttonPressed) in
                    if buttonPressed == DeleteButtonPressed.delete {
                        self.deleteGiftAtIndexPath(indexPath)
                    }
                })
            }
        } else if action == .copy {
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.copyGiftAtIndexPath(indexPath)
            }
        }
        return true
    }
}
