//
//  AZLTabView.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/17.
//

import UIKit
import AZLExtend

public class AZLTabView: UIView {
    
    public var itemLayoutInset:UIEdgeInsets = .zero {
        didSet{
            self.setNeedsLayout()
        }
    }
    public var centerLayoutInset:UIEdgeInsets = .zero {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    public var itemShouldSelectBlock:((_ index:Int) -> Bool)?

    private var itemViews:[AZLBaseTabItemView] = []
    
    private var centerView:UIView?
    private var centerViewTapBlock:(() -> Void)?
    
    private var selectedIndex:Int = 0
    
    private var backgroundView:UIView?

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
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(viewDidTap(gesture:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc
    func viewDidTap(gesture:UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self)
        var index = -1
        for itemView in self.itemViews {
            index += 1
            if itemView.frame.contains(tapLocation) {
                // tabItem被点
                if self.itemShouldSelectBlock?(index) == true {
                    self.select(index: index)
                }
                break
            }
        }
        if self.centerView?.frame.contains(tapLocation) == true {
            // 中间图被点
            self.centerViewTapBlock?()
        }
    }
    
    public func setBackgroundView(view:UIView?) {
        self.backgroundView?.removeFromSuperview()
        if view != nil {
            self.insertSubview(view!, at: 0)
        }
        self.backgroundView = view
    }
    
    public func select(index:Int) {
        if index < self.itemViews.count {
            self.itemViews[self.selectedIndex].updateUI(isSelected: false)
            self.itemViews[index].updateUI(isSelected: true)
            self.selectedIndex = index
        }
    }
    
    public func getSelectIndex() -> Int {
        return self.selectedIndex
    }
    
    func setTabArray(_ tabArray:[(image:UIImage?, selectedImage:UIImage?, name:String, normalColor:UIColor?, selectedColor:UIColor?, normalFont:UIFont?, selectedFont:UIFont?)]) {
        let width = self.bounds.width/4
        let height = self.bounds.height
        var itemViews:[AZLBaseTabItemView] = []
        for tabItem in tabArray {
            let itemView = AZLTabItemView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
            itemView.normalImage = tabItem.image
            if tabItem.selectedImage != nil {
                itemView.selectedImage = tabItem.selectedImage
            }else{
                if tabItem.selectedColor != nil {
                    itemView.selectedImage = tabItem.image?.azl_image(withGradientTintColor: tabItem.selectedColor)
                }else{
                    itemView.selectedImage = tabItem.image
                }
            }
            itemView.nameString = tabItem.name
            itemView.normalColor = tabItem.normalColor
            itemView.seletedColor = tabItem.selectedColor ?? tabItem.normalColor
            itemView.normalFont = tabItem.normalFont
            itemView.selectedFont = tabItem.selectedFont ?? tabItem.normalFont
            
            itemViews.append(itemView)
        }
        self.setTabArray(itemViews: itemViews)
    }
    
    func setTabArray(itemViews:[AZLBaseTabItemView]) {
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
    
    func setCenterView(_ centerView:UIView?, tapBlock:(() -> Void)?) {
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
                let leftItemWidth:CGFloat = (totalWidth/2-self.centerLayoutInset.left)/CGFloat(leftMaxCount)
                var index = 0
                var left:CGFloat = self.itemLayoutInset.left
                while index < leftMaxCount {
                    let itemView = self.itemViews[index]
                    itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: leftItemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                    left += itemView.width
                    index += 1
                }
                
                if rightMaxCount > 0 {
                    let rightItemWidth:CGFloat = (totalWidth/2-self.centerLayoutInset.right)/CGFloat(rightMaxCount)
                    left = self.bounds.width/2+self.centerView!.bounds.width/2+self.centerLayoutInset.right
                    while index < self.itemViews.count {
                        let itemView = self.itemViews[index]
                        itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: rightItemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                        left += itemView.width
                        index += 1
                    }
                }
            }else{
                // 没中间图时的布局
                var index = 0
                let itemWidth = totalWidth/CGFloat(self.itemViews.count)
                var left:CGFloat = self.itemLayoutInset.left
                while index < self.itemViews.count {
                    let itemView = self.itemViews[index]
                    itemView.frame = CGRect.init(x: left, y: self.itemLayoutInset.top, width: itemWidth, height: self.bounds.height-self.itemLayoutInset.top)
                    left += itemView.width
                    index += 1
                }
            }
        }
        
    }
    
}

// 常用背景View创建方法
public extension AZLTabView {
    // 中间镂空背景
    func addCenterHollowBackgroundView(centerTop:CGFloat, color:UIColor) {
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
