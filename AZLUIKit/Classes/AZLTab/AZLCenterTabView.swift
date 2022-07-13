//
//  AZLCenterTabView.swift
//  AZLUIKit
//
//  Created by lizihong on 2022/7/13.
//

import UIKit
import AZLExtendSwift

/**
可以额外带一个中心控件的tabview

常用于首页的底部栏，以及item数量较少的情况
 */
public class AZLCenterTabView: AZLTabView {
    /// itemView的间隔
    public var itemLayoutInset: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 中间View的间隔
    public var centerLayoutInset: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 背景view
    private var backgroundView: UIView?
    /// 中间View
    private var centerView: UIView?
    /// 中间view的点击事件
    private var centerViewTapBlock: (() -> Void)?
    
    /// itemView数组
    private var itemViews: [AZLBaseTabItemView] = []
    
    /// 正在点击的view
    private var touchView: UIView?
    /// 正在点击的view的itemIndex，如果点击的位置不属于itemView时此处为-1
    private var touchIndex: Int = -1
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateUI()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touchView: UIView?
        var touchIndex = -1
        
        if let firstTouch = touches.first {
            let tapLocation = firstTouch.location(in: self)
            var index = -1
            for itemView in self.itemViews {
                index += 1
                if itemView.frame.contains(tapLocation) {
                    // tabItem被点
                    touchIndex = index
                    touchView = itemView
                    itemView.updateUI(isSelected: true)
                    break
                }
            }
            if self.centerView?.frame.contains(tapLocation) == true {
                // 中间图被点
                touchView = self.centerView
                if let view = self.centerView as? AZLSelectable {
                    view.updateUI(isSelected: true)
                }
            }
        }
        
        self.touchView = touchView
        self.touchIndex = touchIndex
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let tapLocation = firstTouch.location(in: self)
            if self.touchView?.frame.contains(tapLocation) == true {
                // 移动到里面
                if let view = self.touchView as? AZLSelectable {
                    view.updateUI(isSelected: true)
                }
            } else {
                // 移动到外面
                if let view = self.touchView as? AZLSelectable {
                    view.updateUI(isSelected: false)
                }
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let tapLocation = firstTouch.location(in: self)
            if self.touchView?.frame.contains(tapLocation) == true {
                // 移动到里面
                if self.touchView == self.centerView {
                    if let view = self.touchView as? AZLSelectable {
                        view.updateUI(isSelected: false)
                    }
                    self.centerViewTapBlock?()
                } else if self.touchIndex != -1 {
                    if self.itemShouldSelectBlock?(self.touchIndex) == true {
                        self.select(index: self.touchIndex)
                    } else if self.selectedIndex == self.touchIndex {
                        self.itemViews[self.selectedIndex].updateUI(isSelected: true)
                    }
                }
            } else {
                // 移动到外面
                if self.touchView == self.centerView, let view = self.touchView as? AZLSelectable {
                    view.updateUI(isSelected: false)
                } else if self.selectedIndex == self.touchIndex {
                    self.itemViews[self.selectedIndex].updateUI(isSelected: true)
                }
            }
        }
        self.touchView = nil
        self.touchIndex = -1
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.selectedIndex == self.touchIndex {
            self.itemViews[self.selectedIndex].updateUI(isSelected: true)
        } else if let view = self.touchView as? AZLSelectable {
            view.updateUI(isSelected: false)
        }
        self.touchView = nil
        self.touchIndex = -1
    }
    
    /// 设置背景View
    public func setBackgroundView(view: UIView?) {
        self.backgroundView?.removeFromSuperview()
        if view != nil {
            self.insertSubview(view!, at: 0)
        }
        self.backgroundView = view
    }
    
    /// 设置当前选中itemView(index < itemViews.count才有效)
    override public func select(index: Int) {
        if index < self.itemViews.count {
            // 取消原来选中的ui
            self.itemViews[self.selectedIndex].updateUI(isSelected: false)
            // 当前选中的ui
            self.itemViews[index].updateUI(isSelected: true)
            self.selectedIndex = index
        }
    }
    
    /// 获取当前选中的Index
    override public func getSelectIndex() -> Int {
        return self.selectedIndex
    }
    
    /// 设置数据
    public func setTabArray(_ tabArray: [AZLTabItem]) {
        let width = self.bounds.width/4
        let height = self.bounds.height
        var itemViews: [AZLBaseTabItemView] = []
        for tabItem in tabArray {
            let itemView = AZLTabItemView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
            itemView.normalImage = tabItem.image
            if tabItem.selectedImage != nil {
                itemView.selectedImage = tabItem.selectedImage
            } else {
                if tabItem.selectedColor != nil {
                    itemView.selectedImage = tabItem.image?.azl_tintImage(color: tabItem.selectedColor!)
                } else {
                    itemView.selectedImage = tabItem.image
                }
            }
            itemView.nameString = tabItem.name
            itemView.normalColor = tabItem.color
            itemView.seletedColor = tabItem.selectedColor ?? tabItem.color
            itemView.normalFont = tabItem.font
            itemView.selectedFont = tabItem.selectedFont ?? tabItem.font
            
            itemViews.append(itemView)
        }
        self.setTabArray(itemViews: itemViews)
    }
    
    /// 设置自定义itemView(设置的view会自动重新布局)
    public func setTabArray(itemViews: [AZLBaseTabItemView]) {
        for itemView in self.itemViews {
            itemView.removeFromSuperview()
        }
        if self.selectedIndex >= itemViews.count {
            self.selectedIndex = 0
        }
        self.itemViews = itemViews
        for itemView in itemViews {
            self.addSubview(itemView)
            itemView.updateUI(isSelected: false)
        }
        self.select(index: self.selectedIndex)
        self.setNeedsLayout()
    }
    
    /// 设置中心View，如果centerView符合AZLSelectable，那么点击的时候会触发其updateUI(isSelected)的方法
    public func setCenterView(_ centerView: UIView?, tapBlock: (() -> Void)?) {
        self.centerView?.removeFromSuperview()
        if centerView != nil {
            self.addSubview(centerView!)
        }
        self.centerView = centerView
        self.centerViewTapBlock = tapBlock
        self.setNeedsLayout()
    }
    
    /// 重新布局UI
    func updateUI() {
        
        var totalWidth = self.bounds.width-self.itemLayoutInset.left-self.itemLayoutInset.right
        if self.centerView != nil {
            totalWidth = totalWidth-self.centerView!.bounds.width
            
            self.centerView?.center = CGPoint.init(x: self.bounds.size.width/2, y: self.centerView!.bounds.height/2+self.centerLayoutInset.top)
        }
        if self.itemViews.count > 0 {
            if self.centerView != nil {
                // 有中间图时的布局
                let leftMaxCount = (self.itemViews.count+1)/2
                let rightMaxCount = self.itemViews.count-leftMaxCount
                // 分开两边
                let leftItemWidth: CGFloat = (totalWidth/2-self.centerLayoutInset.left)/CGFloat(leftMaxCount)
                var index = 0
                var left: CGFloat = self.itemLayoutInset.left
                while index < leftMaxCount {
                    let itemView = self.itemViews[index]
                    itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: leftItemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                    left += itemView.azl_width()
                    index += 1
                }
                
                if rightMaxCount > 0 {
                    let rightItemWidth:CGFloat = (totalWidth/2-self.centerLayoutInset.right)/CGFloat(rightMaxCount)
                    left = self.bounds.width/2+self.centerView!.bounds.width/2+self.centerLayoutInset.right
                    while index < self.itemViews.count {
                        let itemView = self.itemViews[index]
                        itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: rightItemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                        left += itemView.azl_width()
                        index += 1
                    }
                }
            } else {
                // 没中间图时的布局
                var index = 0
                let itemWidth = totalWidth/CGFloat(self.itemViews.count)
                var left: CGFloat = self.itemLayoutInset.left
                while index < self.itemViews.count {
                    let itemView = self.itemViews[index]
                    itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: itemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                    left += itemView.azl_width()
                    index += 1
                }
            }
        }
        
    }
}
