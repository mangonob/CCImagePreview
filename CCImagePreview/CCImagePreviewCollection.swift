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
    @objc optional func imagePreviewCollection(_ collection: CCImagePreviewCollection, currentIndexChanged index: Int)
}


enum CCImagePreviewCollectionStyle: Int {
    case dark
    case light
}


class CCImagePreviewCollection: UICollectionView {
    var currentIndex: Int = 0

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
    
    var style: CCImagePreviewCollectionStyle = .dark {
        didSet {
            switch style {
            case .dark:
                backgroundColor = .black
                visibleCells.forEach { ($0 as? CCImagePreviewCell)?.marginColor = .black }
            case .light:
                backgroundColor = .white
                visibleCells.forEach { ($0 as? CCImagePreviewCell)?.marginColor = .white }
            }
        }
    }
    
    var shouldChangeStyleWhenTap: Bool = true
    
    private lazy var configureOnce: Void = {
        style = .dark
        bounces = true
        alwaysBounceVertical = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        delegate = self
        dataSource = self

        register(CCImagePreviewCell.self, forCellWithReuseIdentifier: previewCellIdentifier)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapHandler(_:)))
        doubleTap.numberOfTapsRequired = 2
        let click = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler(_:)))
        click.require(toFail: doubleTap)
        addGestureRecognizer(click)
        addGestureRecognizer(doubleTap)
    }()

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        _ = configureOnce
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var oldBounds: CGRect!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds != oldBounds {
            collectionViewLayout.invalidateLayout()
            oldBounds = bounds
        }
    }
    
    // MARK: - Action
    @objc private func tapHandler(_ sender: Any) {
        guard shouldChangeStyleWhenTap else { return }
        
        UIView.animate(withDuration: CATransaction.animationDuration(),
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        guard let cell = self else { return }
                        
                        switch cell.style {
                        case .dark:
                            cell.style = .light
                        case .light:
                            cell.style = .dark
                        }
            }, completion: nil)
    }

    @objc private func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        guard let indexPath = indexPathsForVisibleItems.filter({ $0.row == currentIndex }).first,
        let cell = cellForItem(at: indexPath) as? CCImagePreviewCell else { return }
        cell.filpScale(withDoubleTap: sender)
    }
}


extension CCImagePreviewCollection: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = (scrollView.contentOffset.x / scrollView.contentSize.width)
        guard !progress.isNaN else { return }

        let N = CGFloat(previewDataSource?.numberOfImages(inImagePreviewCollection: self) ?? 0)
        
        let standardProgress = min(max(progress, 0), 1)
        let standardIndex = Int(floor(standardProgress * N))
        if standardIndex != currentIndex {
            currentIndex = standardIndex
            previewDelegate?.imagePreviewCollection?(self, currentIndexChanged: currentIndex)
        }
        
        let index = Int(floor(progress * N))
        if progress * N < CGFloat(index) {
            let rate = Float(ceil(progress * N) - progress * N)

            (cellForItem(at: IndexPath(row: index - 1, section: 0))
                as? CCImagePreviewCell)?.marginRate = min(max(-rate, -1), 1)

            (cellForItem(at: IndexPath(row: index, section: 0))
                as? CCImagePreviewCell)?.marginRate = min(max(1 - rate, -1), 1)
        } else {
            let rate = Float(progress * N - floor(progress * N))

            (cellForItem(at: IndexPath(row: index, section: 0))
                as? CCImagePreviewCell)?.marginRate = min(max(-rate, -1), 1)
            
            (cellForItem(at: IndexPath(row: index + 1, section: 0))
                as? CCImagePreviewCell)?.marginRate = min(max(1 - rate, -1), 1)
        }
    }
}


extension CCImagePreviewCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CCImagePreviewCell else { return }
        
        cell.imageUpdated()
        
        switch style {
        case .dark:
            cell.marginColor = .black
        case .light:
            cell.marginColor = .white
        }
    }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewCellIdentifier, for: indexPath) as! CCImagePreviewCell
        cell.link(withImage: previewDataSource?.imagePreviewCollection(self, imageAtIndex: indexPath.row))
        return cell
    }
}
