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
        
        // 设置中间item
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 56, height: 56))
        centerView.backgroundColor = UIColor.red
        centerView.layer.cornerRadius = 28
        let centerImage = UIImageView.init(image: UIImage(named: "add_task"))
        centerView.addSubview(centerImage)
        centerImage.center = CGPoint.init(x: centerView.bounds.size.width/2, y: centerView.bounds.size.height/2)
        self.tabView?.centerLayoutInset = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        self.tabView?.setCenterView(centerView, tapBlock: { [weak self] in
            // 中间按钮被点
            print("中间被点")
            self?.tabViewHeight = 69
        })
        
        // 设置tabItem数据
        self.tabView?.itemLayoutInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        let controller1 = UIViewController()
        controller1.view.backgroundColor = UIColor.green
        
        let controller2 = UIViewController()
        controller2.view.backgroundColor = UIColor.blue
        self.setItemAndControllers(dataArray: [
            (controller: controller1, item: AZLTabItem(name: "Home", image: UIImage(named: "home"), color: UIColor.black, selectedColor: UIColor.red, font: UIFont.systemFont(ofSize: 13))),
            (controller: controller2, item: AZLTabItem(name: "Setting", image: UIImage(named: "setting"), color: UIColor.black, selectedColor: UIColor.red, font: UIFont.systemFont(ofSize: 13)))
        ])
        
        // 设置中心镂空背景
        if let tabView = self.tabView {
            let background = AZLHollowBackgroundView.init(frame: CGRect.init(x: 0, y: 9, width: tabView.bounds.size.width, height: tabView.bounds.size.height))
            background.backgroundColor = UIColor.white
            background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            background.setCenterHollow(centerSize: 56+16, centerY: 28-9, corner: 8)
            tabView.setBackgroundView(view: background)
        }
        
    }

}
