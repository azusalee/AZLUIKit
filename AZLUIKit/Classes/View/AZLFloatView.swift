//
//  AZLFloatView.swift
//  ZeekEC
//
//  Created by lizihong on 2022/9/9.
//

import UIKit

/// 悬浮视图，用于做悬浮效果的
///
/// 负责多按钮布局、点击回调、动画等逻辑
public class AZLFloatView: UIView {
    /// 摆放位置枚举
    public enum EnterLocateType {
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
    }
    
    /// 展开方式
    public enum ExpandType {
        /// 上下展开
        case topBottom
        /// 左右展开
        case leftRight
        /// 环绕展开, radius 半径, totalAngle 总弧度, angleOffset 起始角偏移 (角度用π这样的值，例如π/2就是90°)
        case round(radius: CGFloat, totalAngle: CGFloat, angleOffset: CGFloat)
    }
    
    /// 入口大小
    public var enterSize = CGSize.init(width: 50, height: 50) {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 其他行为按钮的默认大小
    public var actionSize = CGSize.init(width: 40, height: 40)
    /// 位置偏移
    public var enterInset = UIEdgeInsets.init(top: 40, left: 15, bottom: 40, right: 15) {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 摆放位置
    public var locateType: EnterLocateType = .rightBottom {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 展开方式
    public var expandType: ExpandType = .topBottom {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 按钮间的间距
    public var buttonSpace: CGFloat = 10
    
    /// 最后一个action的tag值
    private var lastActionTag: Int = 0
    
    /// 是否展示按钮列表
    private var isShowButtonList = false
    /// 入口按钮
    var enterButton = UIButton.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 50, height: 50)))
    /// 行为按钮
    var actionButtons: [UIButton] = []
    
    /// 点击事件
    public var actionDidTap: ((Int) -> Void)?
    /// 入口点击事件 (不设置，默认为展开/收起action的逻辑)
    public var enterDidTap: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.enterButton.addTarget(self, action: #selector(enterButtonDidTap(_:)), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(blankDidTap(gesture:)))
        self.addGestureRecognizer(tapGesture)
        self.addSubview(self.enterButton)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let superView = self.superview {
            
            self.frame = superView.bounds
            // 入口按钮位置
            switch self.locateType {
                
            case .leftTop:
                self.enterButton.frame = CGRect.init(x: self.enterInset.left, y: self.enterInset.top, width: self.enterSize.width, height: self.enterSize.height)
            case .rightTop:
                self.enterButton.frame = CGRect.init(x: superView.bounds.size.width-self.enterSize.width-self.enterInset.right, y: self.enterInset.top, width: self.enterSize.width, height: self.enterSize.height)
            case .rightBottom:
                self.enterButton.frame = CGRect.init(x: superView.bounds.size.width-self.enterSize.width-self.enterInset.right, y: super.bounds.size.height-self.enterSize.height-self.enterInset.bottom, width: self.enterSize.width, height: self.enterSize.height)
            case .leftBottom:
                self.enterButton.frame = CGRect.init(x: self.enterInset.left, y: super.bounds.size.height-self.enterSize.height-self.enterInset.bottom, width: self.enterSize.width, height: self.enterSize.height)
            }
            
            self.enterButton.layer.cornerRadius = self.enterButton.bounds.size.height/2
            self.layoutActionButtons()
        }
    }
    
    public func setEnterImage(_ image: UIImage?) {
        self.enterButton.setImage(image, for: .normal)
    }
    
    public func setEnterBackground(color: UIColor) {
        self.enterButton.backgroundColor = color
    }
    
    /// 添加action
    @discardableResult
    public func addActionButton(image: UIImage?, title: String? = "") -> UIButton {
        return self.addActionButton(image: image, title: title, size: self.actionSize)
    }
    
    @discardableResult
    public func addActionButton(image: UIImage?, title: String?, size: CGSize) -> UIButton {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = button.bounds.height/2
        button.addTarget(self, action: #selector(actionButtonDidTap(_:)), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        button.tag = self.lastActionTag
        button.setImage(image, for: .normal)
        self.insertSubview(button, at: 0)
        
        self.lastActionTag += 1
        self.actionButtons.append(button)
        
        return button
    }
    
    /// 布局actionButton的位置
    func layoutActionButtons() {
        if self.isShowButtonList {
            // 展开
            var nextCenter = self.enterButton.center
            let buttonSpace = self.buttonSpace
            // 根据展开方式和摆放位置来决定actionButton的位置
            var scaleX: CGFloat = 0
            var scaleY: CGFloat = 0
            var startAngle: CGFloat = 0
            var stepAngle: CGFloat = CGFloat.pi/2
            
            var roundRadius: CGFloat = 0
            switch self.expandType {
            case .topBottom:
                scaleY = 1
            case .leftRight:
                scaleX = 1
            case .round(let radius, let totalAngle, let angleOffset):
                roundRadius = radius
                startAngle += angleOffset
                if self.actionButtons.count > 1 {
                    stepAngle = totalAngle/CGFloat(self.actionButtons.count-1)
                }
            }
            
            switch self.locateType {
            case .leftTop:
                startAngle += CGFloat.pi/2
            case .rightTop:
                startAngle += CGFloat.pi
                scaleX = -scaleX
            case .rightBottom:
                startAngle += CGFloat.pi*1.5
                scaleX = -scaleX
                scaleY = -scaleY
            case .leftBottom:
                scaleY = -scaleY
            }
            nextCenter.y += (self.enterSize.height+buttonSpace)*scaleY
            nextCenter.x += (self.enterSize.width+buttonSpace)*scaleX
            for i in 0..<actionButtons.count {
                let button = actionButtons[i]
                let nextAngle = startAngle+stepAngle*CGFloat(i)
                button.center = CGPoint.init(x: nextCenter.x+roundRadius*sin(nextAngle), y: nextCenter.y-roundRadius*cos(nextAngle))
                nextCenter.y += (button.bounds.size.height+buttonSpace)*scaleY
                nextCenter.x += (button.bounds.size.width+buttonSpace)*scaleX
            }
        } else {
            // 收起，全部回到入口下面
            for button in actionButtons {
                button.center = self.enterButton.center
            }
        }
    }
    
    /// 展示按钮列表
    func showActionList() {
        //self.isHidden = false
        self.isShowButtonList = true
        
        UIView.animate(withDuration: 0.275) {
            self.layoutActionButtons()
        } completion: { isComplete in
            
        }
        
    }
    
    /// 隐藏按钮列表
    func hideActionList() {
        self.isShowButtonList = false
        UIView.animate(withDuration: 0.275) {
            self.layoutActionButtons()
        } completion: { isComplete in
            //self.isHidden = true
        }
    }
    
    /// 点击action
    @objc
    func actionButtonDidTap(_ button: UIButton) {
        self.actionDidTap?(button.tag)
    }
    
    /// 点击入口
    @objc
    func enterButtonDidTap(_ button: UIButton) {
        // 有自定义逻辑
        if self.enterDidTap != nil {
            self.enterDidTap?()
            return
        }
        // 走默认逻辑
        if self.isShowButtonList {
            self.hideActionList()
        } else {
            self.showActionList()
        }
    }
    
    /// 点击空白
    @objc
    func blankDidTap(gesture: UITapGestureRecognizer) {
        self.hideActionList()
    }
    
    // 拦截点击
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isUserInteractionEnabled == false {
            return nil
        }
        if self.enterButton.frame.contains(point) {
            return self.enterButton
        }
        for button in self.actionButtons {
            if button.frame.contains(point) {
                return button
            }
        }
        if self.isShowButtonList {
            return self
        }
        
        return nil
    }
}
