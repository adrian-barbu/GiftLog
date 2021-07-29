//
//  ImagesCollectionView.swift
//  GiftLogApp
//
//  Created by Webs The Word on 4/27/17.
//  Copyright © 2017 Gift Log App. All rights reserved.
//

import UIKit

let marginValue: CGFloat = 5.0

protocol ImagesCollectionViewDelegate: class {
    func imagesCollectionViewDidSelectImageAtIndex(_ index: Int)
}

class ImagesCollectionView: UIView {

    // MARK: IBOutlets
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    
    weak var delegate: ImagesCollectionViewDelegate?
    var giftImages = [GiftImage]()
    
    // MARK: Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        mainInitializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        mainInitializer()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ImagesCollectionView", bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    // MARK: Custom methods
    
    func mainInitializer() {
        setCollectionView()
    }
    
    func setCollectionView() {
        collectionView.register(UINib(nibName: ImageCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCellIdentifier)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: marginValue)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
}

// MARK: CollectionView DataSource and Delegate

extension ImagesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giftImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCellIdentifier, for: indexPath) as! ImageCollectionViewCell
        if indexPath.row == giftImages.count {
            cell.giftImageView.isHidden = true
            cell.addImageView.isHidden = false
        } else {
            cell.giftImageView.kf.setImage(with: URL(string: giftImages[indexPath.row].url))
            cell.giftImageView.isHidden = false
            cell.addImageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == giftImages.count {
            NotificationCenterManager.postNotificationThatUserPressedAddImageAtGift()
        } else {
            delegate?.imagesCollectionViewDidSelectImageAtIndex(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

