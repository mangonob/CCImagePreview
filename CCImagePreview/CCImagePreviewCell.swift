//
//  CCImagePreviewCell.swift
//  ImageBrowser
//
//  Created by 高炼 on 2018/6/12.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit

class CCImagePreviewCell: UICollectionViewCell {
    lazy var scrollView = UIScrollView()
    lazy var zoomView = UIView()
    lazy var imageView = UIImageView()
    private lazy var marginView = UIView()
    
    var marginColor: UIColor? {
        get {
            return marginView.backgroundColor
        }
        set {
            marginView.backgroundColor = newValue
        }
    }
    
    fileprivate var image: UIImage? {
        didSet {
            imageUpdated()
        }
    }
    
    var marginLength: CGFloat = 40

    var marginRate: Float = 0 {
        didSet {
            marginRateUpdated()
        }
    }
    
    private func marginRateUpdated() {
        if marginRate == 0 {
            if marginView.superview != nil {
                marginView.removeFromSuperview()
            }
        } else {
            if marginView.superview == nil {
                contentView.addSubview(marginView)
            }
            
            if marginRate > 0 {
                let leftTop = CGPoint(x: zoomView.bounds.minX, y: zoomView.bounds.minY)
                let width = max(0, zoomView.convert(leftTop, to: contentView).x)
                    + CGFloat(marginRate) * marginLength
                marginView.frame = contentView.bounds.divided(atDistance: width, from: .minXEdge).slice
            } else {
                let rightTop = CGPoint(x: zoomView.bounds.maxX, y: zoomView.bounds.maxY)
                let width = max(0, contentView.bounds.maxX - zoomView.convert(rightTop, to: contentView).x)
                    - CGFloat(marginRate) * marginLength
                marginView.frame = contentView.bounds.divided(atDistance: width, from: .maxXEdge).slice
            }
        }
    }
    
    func imageUpdated() {
        guard let image = image else {
            scrollView.removeFromSuperview()
            return
        }
        
        if scrollView.superview == nil {
            contentView.insertSubview(scrollView, at: 0)
        }
        
        imageView.image = image
        zoomView.bounds = .init(origin: .zero, size: image.size)
        updateZoomScale()
        layoutViews()
        fitZoom()
    }

    fileprivate func updateZoomScale() {
        guard let image = image else { return }
        let ws = scrollView.bounds.width / image.size.width
        let hs = scrollView.bounds.height / image.size.height
        
        scrollView.minimumZoomScale = min(min(1, ws), hs)
        scrollView.maximumZoomScale = max(max(2, ws), hs)
    }
    
    fileprivate func fitZoom() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateContentOrigin()
    }
    
    fileprivate func updateContentOrigin() {
        var frame = zoomView.frame
        let x = (scrollView.bounds.size.width - frame.size.width) / 2
        let y = (scrollView.bounds.size.height - frame.size.height) / 2
        frame.origin = CGPoint(x: max(x, 0), y: max(y, 0))
        zoomView.frame = frame
    }
    
    private lazy var configureOnce: Void = {
        scrollView.backgroundColor = .clear
        zoomView.backgroundColor = .clear
        imageView.backgroundColor = .clear
        
        scrollView.addSubview(zoomView)
        zoomView.addSubview(imageView)
        
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }()
    
    private var oldSize: CGSize = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = configureOnce
        
        layoutViews()

        marginRateUpdated()
        
        if oldSize != bounds.size {
            oldSize = bounds.size
            fitZoom()
        }
    }
    
    private func layoutViews() {
        guard scrollView.superview != nil else { return }
        
        scrollView.frame = contentView.bounds
        imageView.frame = zoomView.bounds
        updateZoomScale()
    }
    
    private var isPending = false
    override func prepareForReuse() {
        super.prepareForReuse()
        isPending = false
    }
    
    func link(withImage image: CCImage?) {
        // Clear old image
        self.image = nil
        
        guard let image = image else {
            return
        }
        
        switch image {
        case .image(let image):
            self.image = image
        case .url(let url):
            isPending = true
            
            loadImage(fromURL: url, completion: { [weak self] (image) in
                guard let cell = self else { return }
                guard let image = image else { return }
                if cell.isPending {
                    cell.image = image
                }
            })
        }
    }
    
    func flipScale(withDoubleTap sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.flipScaleWithOutAnimate(withDoubleTap: sender)
        }
    }
    
    private func flipScaleWithOutAnimate(withDoubleTap sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            var locationInZoomView = sender.location(in: zoomView)
            locationInZoomView.x /= zoomView.bounds.size.width
            locationInZoomView.y /= zoomView.bounds.size.height
            
            let locationInContent = sender.location(in: contentView)
            
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: false)
            
            locationInZoomView.x *= zoomView.frame.size.width
            locationInZoomView.y *= zoomView.frame.size.height
            let origin = CGPoint(x: locationInZoomView.x - locationInContent.x,
                                 y: locationInZoomView.y - locationInContent.y)
            let rect = CGRect(origin: origin, size: contentView.bounds.size)
            scrollView.scrollRectToVisible(rect, animated: false)
        } else if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }
}


extension CCImagePreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentOrigin()
    }
}
