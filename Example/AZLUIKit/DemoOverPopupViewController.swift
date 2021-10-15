//
//  DemoOverPopupViewController.swift
//  AZLUIKit_Example
//
//  Created by lizihong on 2021/9/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AZLUIKit

class DemoOverPopupViewController: AZLOverPopupViewController {

    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置代理
        self.overPopupDelegate = self
        
        let processView = AZLProcessView.init(frame: CGRect.init(x: 30, y: 200, width: 200, height: 10))
        processView.processColor = UIColor.orange
        processView.process = 1
        processView.backgroundColor = UIColor.gray
        self.containerView.addSubview(processView)
    }

}

// 实现overPopup的相关代理方法
extension DemoOverPopupViewController: AZLOverPopupViewControllerDelegate {
    func overPopupView() -> UIView? {
        self.containerView
    }
    
    func overPopupViewMinHeight() -> CGFloat {
        return 567
    }
    
    func overPopupViewMaxHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height-UIApplication.shared.statusBarFrame.size.height
    }
    
    func overPopupViewHeightShouldChange(height: CGFloat) {
        self.containerHeight.constant = height
    }
}
