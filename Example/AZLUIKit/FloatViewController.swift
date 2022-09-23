//
//  FloatViewController.swift
//  AZLUIKit_Example
//
//  Created by lizihong on 2022/9/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import AZLUIKit

class FloatViewController: UIViewController {
    
    let floatView = AZLFloatView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 200))
    
    var type = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.floatView.frame = self.view.bounds
        self.floatView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(self.floatView)
        
        // 入口设置
        self.floatView.setEnterBackground(color: UIColor.systemRed)
        self.floatView.setEnterImage(UIImage(named: "home"))
        
        // action设置
        self.floatView.addActionButton(image: nil, title: "1")
        self.floatView.addActionButton(image: nil, title: "2")
        self.floatView.addActionButton(image: nil, title: "3")
        self.floatView.addActionButton(image: nil, title: "4")
        self.floatView.addActionButton(image: nil, title: "5")
        
        // action点击回调
        self.floatView.actionDidTap = { [weak self] index in
            print("action \(index) 点击")
            switch index {
            case 0:
                self?.floatView.locateType = .leftTop
            case 1:
                self?.floatView.locateType = .rightTop
            case 2:
                self?.floatView.locateType = .rightBottom
            case 3:
                self?.floatView.locateType = .leftBottom
            case 4:
                self?.changeExpandType()
                
            default:
                break
            }
        }
        
        self.floatView.enterInset = UIEdgeInsets.init(top: 80, left: 15, bottom: 40, right: 15)
        self.floatView.locateType = .rightBottom
        self.floatView.expandType = .round(radius: 66, totalAngle: CGFloat.pi*0.6, angleOffset: -CGFloat.pi*0.05)
    }
    
    func changeExpandType() {
        if type == 0 {
            self.floatView.expandType = .topBottom
            type = 1
        } else if type == 1 {
            self.floatView.expandType = .leftRight
            type = 2
        } else {
            self.floatView.expandType = .round(radius: 66, totalAngle: CGFloat.pi*0.6, angleOffset: -CGFloat.pi*0.05)
            type = 0
        }
    }

}
