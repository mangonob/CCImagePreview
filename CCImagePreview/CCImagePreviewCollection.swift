//
//  CCImagePreviewCollection.swift
//  ImageBrowser
//
//  Created by 高炼 on 2018/6/12.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit


protocol CCImagePreviewCollectionDataSource: AnyObject {
    func numberOfImages(inImagePreviewCollection collection: CCImagePreviewCollection) -> Int
    func imagePreviewCollection(_ collection: CCImagePreviewCollection, imageAtIndex index: Int) -> CCImage?
}

@objc protocol CCImagePreviewCollectionDelegate {
}


class CCImagePreviewCollection: UICollectionView {
    weak var previewDataSource: CCImagePreviewCollectionDataSource? {
        didSet {
            reloadData()
        }
    }
    
    weak var previewDelegate: CCImagePreviewCollectionDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    fileprivate lazy var previewCellIdentifier = UUID().uuidString
    
    private lazy var configureOnce: Void = {
        backgroundColor = .black
        bounces = true
        alwaysBounceVertical = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        delegate = self
        dataSource = self
        
        register(CCImagePreviewCollection.self, forCellWithReuseIdentifier: previewCellIdentifier)
    }()

    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        _ = configureOnce
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CCImagePreviewCollection: UICollectionViewDelegate {
}


extension CCImagePreviewCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


extension CCImagePreviewCollection: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewDataSource?.numberOfImages(inImagePreviewCollection: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CCImagePreviewCell
        return cell
    }
}
