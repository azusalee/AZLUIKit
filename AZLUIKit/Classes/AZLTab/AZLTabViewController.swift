//
//  AZLTabViewController.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/18.
//

import UIKit

/**
底部固定有一个tabview的页面，常用于主页

一般用法是继承这个类，然后再自己添加自定义的子VC，根据tabView的回调进行页面的切换逻辑
 */
open class AZLTabViewController: UIViewController {
    
    /// viewDidLoad后可以使用
    public var tabView: AZLCenterTabView?
    /// viewDidLoad后可以使用，在tabView之下
    public var contentView: UIView?
    /// 子内容页面数组
    private var contentVCs: [UIViewController] = []
    
    /// tabView的高度(不含safeArea)
    public var tabViewHeight: CGFloat = 79 {
        didSet {
            self.view.setNeedsLayout()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        let contentView = UIView.init(frame: self.view.bounds)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(contentView)
        self.contentView = contentView
        
        let tabViewHeight: CGFloat = self.tabViewHeight
        self.tabView = AZLCenterTabView.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height-tabViewHeight, width: self.view.bounds.size.width, height: tabViewHeight))
        self.tabView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.view.addSubview(self.tabView!)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 自动根据safeArea调整tabView的高度
        var safeBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeBottom = self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        }
        let tabViewHeight: CGFloat = self.tabViewHeight+safeBottom
        self.tabView?.frame = CGRect.init(x: 0, y: self.view.bounds.size.height-tabViewHeight, width: self.view.bounds.size.width, height: tabViewHeight)
    }
    
    /// 设置tabItem数据和对应的controller
    /// 此方法会设置tabView.itemShouldSelectBlock的回调，如果需要自定义点击逻辑，请不要用此方法设置数据
    /// - Parameter dataArray: controller和tabItem数据
    public func setItemAndControllers(dataArray: [(controller: UIViewController, item: AZLTabItem)]) {
        if dataArray.count == 0 {
            // 数据不能为空
            return
        }
        // 先去掉旧的页面
        for controller in self.contentVCs {
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    
        var items: [AZLTabItem] = []
        var controllers: [UIViewController] = []
        for data in dataArray {
            items.append(data.item)
            controllers.append(data.controller)
            self.addChild(data.controller)
        }
        self.contentVCs = controllers
        self.tabView?.setTabArray(items)
        
        self.tabView?.itemShouldSelectBlock = { [weak self] (index) in
            // item被点
            self?.showContentController(index: index)
            return true
        }
        
        if let index = self.tabView?.getSelectIndex() {
            self.showContentController(index: index)
        }
    }
    
    /// 显示指定的vc
    func showContentController(index: Int) {
        if index < self.contentVCs.count {
            let controller = self.contentVCs[index]
            self.contentView?.addSubview(controller.view)
            controller.view.frame = self.view.bounds
        }
    }
}
