//
//  DemoTabViewController.swift
//  AZLUIKit_Example
//
//  Created by lizihong on 2021/9/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AZLUIKit

class DemoTabViewController: AZLTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置item
        self.tabView?.itemLayoutInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        
        self.tabView?.setTabArray([
            (image:UIImage(named: "home"), selectedImage:nil, name:"Home", normalColor:UIColor.black, selectedColor:UIColor.red, normalFont:UIFont.systemFont(ofSize: 13), selectedFont:UIFont.systemFont(ofSize: 13)),
            (image:UIImage(named: "profile"), selectedImage:nil, name:"Profile", normalColor:UIColor.black, selectedColor:UIColor.red, normalFont:UIFont.systemFont(ofSize: 13), selectedFont:UIFont.systemFont(ofSize: 13))
        ])
        
        // 设置中间item
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 56, height: 56))
        centerView.backgroundColor = UIColor.red
        centerView.layer.cornerRadius = 28
        let centerImage = UIImageView.init(image: UIImage(named: "add_task"))
        centerView.addSubview(centerImage)
        centerImage.center = CGPoint.init(x: centerView.bounds.size.width/2, y: centerView.bounds.size.height/2)
        self.tabView?.centerLayoutInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        self.tabView?.setCenterView(centerView, tapBlock: {
            // 中间按钮被点
            print("中间被点")
        })
        
        self.tabView?.itemShouldSelectBlock = { (index) in
            // item被点
            print("item \(index) 被点")
            return true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 画中间镂空
        self.tabView?.addCenterHollowBackgroundView(centerTop: 9, color: UIColor.white)
        
    }

}
