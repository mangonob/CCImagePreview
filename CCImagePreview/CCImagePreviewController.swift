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

class CCImagePreviewController: UIViewController {
    weak var delegate: CCImagePreviewControllerDelegate?

    var images = [CCImage]() {
        didSet {
            guard isViewLoaded else { return }
            preview.reloadData()
        }
    }
    
    private lazy var preview = CCImagePreviewCollection()
    
    override func viewDidLoad() {
        images = [
            #imageLiteral(resourceName: "image1"),#imageLiteral(resourceName: "image2"),#imageLiteral(resourceName: "image3")
            ].map { CCImage.image($0) }
        
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
        return images.count
    }
    
    func imagePreviewCollection(_ collection: CCImagePreviewCollection, imageAtIndex index: Int) -> CCImage? {
        return images[index]
    }
}


extension CCImagePreviewController: CCImagePreviewCollectionDelegate {
    func imagePreviewCollection(_ collection: CCImagePreviewCollection, currentIndexChanged index: Int) {
        delegate?.imagePreviewController?(self, selectImageAtIndex: index)
    }
}

