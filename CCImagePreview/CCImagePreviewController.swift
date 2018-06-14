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
    weak var delegate: CCImagePreviewControllerDelegate?
    weak var dataSource: CCImagePreviewControllerDataSource? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        preview.reloadData()
    }
    
    var currentIndex: Int = 0 {
        didSet {
            preview.setCurrentIndex(currentIndex, animated: false)
        }
    }
    
    var images = [CCImage]() {
        didSet {
            guard isViewLoaded else { return }
            preview.reloadData()
        }
    }
    
    private var leastInteractionScrollView: UIScrollView!
    private lazy var preview = CCImagePreviewCollection()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        preview.previewDataSource = self
        preview.previewDelegate = self
        view = preview
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
