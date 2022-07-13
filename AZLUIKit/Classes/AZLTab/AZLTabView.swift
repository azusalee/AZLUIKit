//
//  AZLTabView.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/17.
//

import UIKit
import AZLExtendSwift

public class AZLTabView: UIView {
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
    /// itemView被点击时的回调
    public var itemShouldSelectBlock: ((_ index:Int) -> Bool)?

    /// itemView数组
    private var itemViews: [AZLBaseTabItemView] = []
    /// 中间View
    private var centerView: UIView?
    /// 中间view的点击事件
    private var centerViewTapBlock: (() -> Void)?
    /// 当前选中索引
    private var selectedIndex: Int = 0
    /// 背景view
    private var backgroundView: UIView?
    
    /// 正在点击的view
    private var touchView: UIView?
    /// 正在点击的view的itemIndex，如果点击的位置不属于itemView时此处为-1
    private var touchIndex: Int = -1

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateUI()
    }
    
    func setup() {
        //let gesture = UITapGestureRecognizer.init(target: self, action: #selector(viewDidTap(gesture:)))
        //self.addGestureRecognizer(gesture)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touchView: UIView?
        var index = -1
        if let firstTouch = touches.first {
            let tapLocation = firstTouch.location(in: self)
            
            for itemView in self.itemViews {
                index += 1
                if itemView.frame.contains(tapLocation) {
                    // tabItem被点
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
        self.touchIndex = index
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
                if self.touchView == self.centerView, let view = self.touchView as? AZLSelectable {
                    view.updateUI(isSelected: false)
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
    public func select(index: Int) {
        if index < self.itemViews.count {
            self.itemViews[self.selectedIndex].updateUI(isSelected: false)
            self.itemViews[index].updateUI(isSelected: true)
            self.selectedIndex = index
        }
    }
    
    /// 获取当前选中的Index
    public func getSelectIndex() -> Int {
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
    
    /// 设置自定义itemView，这里设置的view不会自动排列，需要自己设置好frame
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

// 常用背景View创建方法
public extension AZLTabView {
    /// 中间半圆镂空背景，需要设置centerView后，再设置才有效
    func addCenterHollowBackgroundView(centerTop: CGFloat, color: UIColor) {
        let corner:CGFloat = 8
        let centerSize:CGFloat = self.centerView?.bounds.size.width ?? 0
        let centerInset:CGFloat = self.centerLayoutInset.left
        let height:CGFloat = self.bounds.size.height-centerTop
        let view = UIView.init(frame: CGRect.init(x: 0, y: centerTop, width: self.bounds.size.width, height: height));
        view.backgroundColor = color
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 0))
        let totalWidth = UIScreen.main.bounds.width
        path.addLine(to: CGPoint.init(x: (totalWidth-centerSize-centerInset*2)/2-corner, y: 0))
        
        path.addArc(withCenter: CGPoint.init(x: (totalWidth-centerSize-centerInset*2)/2-corner, y: corner), radius: corner, startAngle:-CGFloat.pi/2,  endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint.init(x: (totalWidth-centerSize-centerInset*2)/2, y: centerSize/2-centerTop))
        
        path.addArc(withCenter: CGPoint.init(x: totalWidth/2, y: centerSize/2-centerTop), radius: centerSize/2+centerInset, startAngle:-CGFloat.pi,  endAngle: 0, clockwise: false)
        
        path.addLine(to: CGPoint.init(x: (totalWidth+centerSize+centerInset*2)/2, y: corner))

        path.addArc(withCenter: CGPoint.init(x: (totalWidth+centerSize+centerInset*2)/2+corner, y: corner), radius: corner, startAngle:-CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: true)
        
        path.addLine(to: CGPoint.init(x: totalWidth, y: 0))
        path.addLine(to: CGPoint.init(x: totalWidth, y: height))
        path.addLine(to: CGPoint.init(x: 0, y: height))
        path.addLine(to: CGPoint.init(x: 0, y: 0))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = view.bounds
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        self.setBackgroundView(view: view)
    }
}
