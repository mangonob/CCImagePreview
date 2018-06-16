//
//  CCImagePreviewTransition.swift
//  CCImagePreview
//
//  Created by 高炼 on 2018/6/16.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit
import SDWebImage


protocol CCImagePreviewTransitionDelegate: AnyObject {
    func targetColor(forTransition transition: CCImagePreviewTransition) -> UIColor?
}

class CCImagePreviewTransition: NSObject, UIViewControllerAnimatedTransitioning {
    weak var delegate: CCImagePreviewTransitionDelegate!
    var initialView: UIView
    var isPresent: Bool
    var targetView: UIView!
    lazy var imageView = UIImageView()
    lazy var background = UIView()

    init(delegate: CCImagePreviewTransitionDelegate, initialView: UIView, image: CCImage, isPresent: Bool = true, targetView: UIView? = nil) {
        self.delegate = delegate
        self.initialView = initialView
        self.isPresent = isPresent
        self.targetView = targetView
        super.init()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.image = nil
        switch image {
        case .image(let image):
            imageView.image = image
        case .url(let url):
            imageView.sd_setImage(with: url, completed: nil)
        }
    }

    private lazy var duration = CATransaction.animationDuration()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            presentTransition(using: transitionContext)
        } else {
            dismissTransition(using: transitionContext)
        }
    }
    
    func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from)?.view.snapshotView(afterScreenUpdates: false) else { return }
        guard let to = transitionContext.viewController(forKey: .to)?.view else { return }
        let container = transitionContext.containerView
        
        initialView.alpha = 0
        
        from.frame = container.bounds
        container.addSubview(from)

        background.frame = container.bounds
        background.backgroundColor = delegate.targetColor(forTransition: self)
        container.addSubview(background)
        background.alpha = 0

        to.frame = container.bounds
        container.addSubview(to)
        to.alpha = 0

        imageView.frame = container.convert(initialView.bounds, from: initialView)
        container.addSubview(imageView)
        
        var targetRect: CGRect? = nil
        if let imageSize = imageView.image?.size {
            let scale = min(container.bounds.width / imageSize.width, container.bounds.height / imageSize.height)
            let newSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            targetRect = CGRect(x: container.bounds.midX - newSize.width / 2, y: container.bounds.midY - newSize.height / 2,
                                width: newSize.width, height: newSize.height)
        }

        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.background.alpha = 1
            self?.imageView.frame = targetRect ?? container.bounds
        }) { [weak self] (finished) in
            self?.imageView.removeFromSuperview()
            self?.background.removeFromSuperview()
            to.alpha = 1

            transitionContext.completeTransition(finished)
        }
    }
    
    func dismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to)?.view.snapshotView(afterScreenUpdates: false) else { return }
        guard let targetView = targetView else {
            fatalError("\(self): targetRect can not be nil when dismiss.")
        }
        let container = transitionContext.containerView
        
        to.frame = container.bounds
        container.addSubview(to)
        
        imageView.frame = targetView.frame
        container.addSubview(imageView)
        
        let targetRect = container.convert(initialView.bounds, from: initialView)
        UIView.animate(withDuration: duration, animations: {
            self.imageView.frame = targetRect
        }) { [weak self] (finished) in
            self?.imageView.removeFromSuperview()
            self?.initialView.alpha = 1
            transitionContext.completeTransition(finished)
        }
    }
}
