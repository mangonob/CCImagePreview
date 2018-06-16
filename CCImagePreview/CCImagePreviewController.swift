//
//  CCImagePreviewController.swift
//  ImageBrowser
//
//  Created by 高炼 on 2018/6/12.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit

@objc protocol CCImagePreviewControllerDelegate {
    @objc optional func imagePreviewController(_ controller: CCImagePreviewController, selectImageAtIndex index: Int)
}

protocol CCImagePreviewControllerDataSource: AnyObject {
    func numberOfImages(inPreviewController controller: CCImagePreviewController) -> Int
    func imagePreviewController(_ controller: CCImagePreviewController, imageAtIndex index: Int) -> CCImage?
}

class CCImagePreviewController: UIViewController {
    var initialView: UIView!
    
    weak var delegate: CCImagePreviewControllerDelegate?
    weak var dataSource: CCImagePreviewControllerDataSource? {
        didSet {
            reloadData()
        }
    }
    
    private (set) lazy var configureOnce: Void = {
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        _ = configureOnce
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func reloadData() {
        preview.reloadData()
    }
    
    var currentIndex: Int = 0 {
        didSet {
            preview.setCurrentIndex(currentIndex, animated: false)
        }
    }
    
    private var leastInteractionScrollView: UIScrollView!
    private lazy var preview = CCImagePreviewCollection()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        preview.previewDataSource = self
        preview.previewDelegate = self
        preview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preview.frame = view.bounds
        view.addSubview(preview)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(_:)))
        pan.cancelsTouchesInView = false
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Action
    private lazy var startCenter: CGPoint = .zero
    private lazy var contentOriginEnded: Bool = true
    @objc private func panHandler(_ sender: UIPanGestureRecognizer) {
        guard let scrollView = view.hitTest(sender.location(in: view), with: nil) as? UIScrollView,
            let zoomView = scrollView.subviews.first,
            let cell = scrollView.superview?.superview as? CCImagePreviewCell else { return }
        
        let progress = min(max(sender.translation(in: scrollView).y / 100, 0), 1)
        
        switch sender.state {
        case .began:
            let v = sender.velocity(in: scrollView)
            guard v.y > 0 && abs(atan(v.x / v.y)) < CGFloat.pi / 6 else {
                sender.isEnabled = false
                sender.isEnabled = true
                return
            }
        
            startCenter = zoomView.center
            scrollView.isScrollEnabled = false
            preview.isScrollEnabled = false
        case .changed:
            guard !scrollView.isZooming else { return }
            guard !scrollView.isTracking else { return }
            zoomView.center = CGPoint(x: startCenter.x + sender.translation(in: scrollView).x,
                                      y: startCenter.y + sender.translation(in: scrollView).y)
            preview.backgroundAlpha = 1 - progress
        default:
            scrollView.isScrollEnabled = true
            preview.isScrollEnabled = true
            if progress < 1 {
                contentOriginEnded = false
                UIView.animate(withDuration: CATransaction.animationDuration(), animations: { [weak self] in
                    cell.updateContentOrigin()
                    self?.preview.backgroundAlpha = 1
                    }, completion: { [weak self] (_) in
                        self?.contentOriginEnded = true
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}


extension CCImagePreviewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension CCImagePreviewController: CCImagePreviewCollectionDataSource {
    func numberOfImages(inImagePreviewCollection collection: CCImagePreviewCollection) -> Int {
        return dataSource?.numberOfImages(inPreviewController: self) ?? 0
    }
    
    func imagePreviewCollection(_ collection: CCImagePreviewCollection, imageAtIndex index: Int) -> CCImage? {
        return dataSource?.imagePreviewController(self, imageAtIndex: index)
    }
}


extension CCImagePreviewController: CCImagePreviewCollectionDelegate {
    func imagePreviewCollection(_ collection: CCImagePreviewCollection, currentIndexChanged index: Int) {
        delegate?.imagePreviewController?(self, selectImageAtIndex: index)
    }
}


extension CCImagePreviewController: CCImagePreviewTransitionDelegate {
    func targetColor(forTransition transition: CCImagePreviewTransition) -> UIColor? {
        return preview.backgroundColor
    }
}


extension CCImagePreviewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let initialView = initialView else {
            fatalError("\(self) initialView can not be nil.")
        }
        return CCImagePreviewTransition(delegate: self, initialView: initialView, image: (dataSource?.imagePreviewController(self, imageAtIndex: 2))!, isPresent: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let scrollView = view.hitTest(CGPoint(x: view.bounds.midX, y: view.bounds.midY), with: nil),
            let zoomView = scrollView.subviews.first else { return nil }
        
        return CCImagePreviewTransition(delegate: self, initialView: initialView, image: (dataSource?.imagePreviewController(self, imageAtIndex: currentIndex))!, isPresent: false, targetView: zoomView)
    }
}

