//
//  AZLTabViewController.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/18.
//

import UIKit

open class AZLTabViewController: UIViewController {

    public var tabView:AZLTabView?
    /// tabView的高度(不含safeArea)
    public var tabViewHeight:CGFloat = 79

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabViewHeight:CGFloat = self.tabViewHeight
        self.tabView = AZLTabView.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height-tabViewHeight, width: self.view.bounds.size.width, height: tabViewHeight))
        self.tabView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.view.addSubview(self.tabView!)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 自动根据safeArea调整tabView的高度
        var safeBottom:CGFloat = 0
        if #available(iOS 11.0, *) {
            safeBottom = self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        }
        let tabViewHeight:CGFloat = self.tabViewHeight+safeBottom
        self.tabView?.frame = CGRect.init(x: 0, y: self.view.bounds.size.height-tabViewHeight, width: self.view.bounds.size.width, height: tabViewHeight)
    }
}
