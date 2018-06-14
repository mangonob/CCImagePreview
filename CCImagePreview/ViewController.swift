//
//  ViewController.swift
//  CCImagePreview
//
//  Created by 高炼 on 2018/6/14.
//  Copyright © 2018年 BaiYiYuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var images: [CCImage] = {
        let imageURLStrings = [
            "http://devstreaming.apple.com/videos/wwdc/2015/1014o78qhj07pbfxt9g7/101/images/101_734x413.jpg",
            "https://www.apple.com/apple-events/june-2016/meta/og.png?201806020537",
            "https://cdn0.tnwcdn.com/wp-content/blogs.dir/1/files/2017/06/Apple-WWDC-2017-796x398.jpg",
            "http://media.idownloadblog.com/wp-content/uploads/2018/03/iPhone-8-Plus-dark-WWDC-logo-basvanderploeg.jpeg"
        ]
        
        return imageURLStrings.map { CCImage.url(URL(string: $0)!) }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func previewAction(_ sender: Any) {
        let vc = CCImagePreviewController()
        vc.dataSource = self
        vc.delegate = self
        vc.currentIndex = 2
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
}


extension ViewController: CCImagePreviewControllerDelegate {
}

extension ViewController: CCImagePreviewControllerDataSource {
    func numberOfImages(inPreviewController controller: CCImagePreviewController) -> Int {
        return images.count
    }
    
    func imagePreviewController(_ controller: CCImagePreviewController, imageAtIndex index: Int) -> CCImage? {
        return images[index]
    }
}
