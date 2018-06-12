//
//  ImagePreviewCell.swift
//  ImageBrowser
//
//  Created by 高炼 on 2018/6/11.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit

class ImagePreviewCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var red: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 0.1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        updateContentFrame()
    }
    
    fileprivate func updateContentFrame() {
        var frame = red.frame
        let x = (scrollView.bounds.size.width - frame.size.width) / 2
        let y = (scrollView.bounds.size.height - frame.size.height) / 2
        frame.origin = CGPoint(x: max(x, 0), y: max(y, 0))
        red.frame = frame
    }
}


extension ImagePreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return red
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentFrame()
    }
}
