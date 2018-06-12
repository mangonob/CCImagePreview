//
//  CCImagePreviewCell+SDWebImage.swift
//  CCImagePreview
//
//  Created by 高炼 on 2018/6/12.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import Foundation
import SDWebImage


extension CCImagePreviewCell {
    func loadImage(fromURL url: URL, completion: ((UIImage?) -> Void)?) {
        SDWebImageManager.shared().loadImage(with: url, options: [], progress: nil) { (image, _, _, _, _, _) in
            completion?(image)
        }
    }
}
