//
//  KSFullOverViewController.swift
//  KSUser
//
//  Created by lizihong on 2020/3/20.
//  Copyright © 2020 KS. All rights reserved.
//

import UIKit
import AZLExtendSwift

public protocol AZLOverPopupViewControllerDelegate: NSObjectProtocol {
    
    /// require 返回需要从下往上出现的view
    func overPopupView() -> UIView?
    
    // 下面几个回调方法，需要准确设置，否则拖动动画会不太准确
    /// option 主要内容view高度将要变化的回调
    func overPopupViewHeightShouldChange(height: CGFloat)
    /// option popup view的最小高度(默认为屏幕高度的一半)
    func overPopupViewMinHeight() -> CGFloat
    /// option popup view的最大高度(默认为屏幕高度-状态栏高度)
    func overPopupViewMaxHeight() -> CGFloat
}

// 代理方法默认实现
public extension AZLOverPopupViewControllerDelegate {
    /// 默认直接修改overPopupView的高度约束
    func overPopupViewHeightShouldChange(height: CGFloat) {
        if let popupView = self.overPopupView() {
            // 检查是否通过约束来调整高度
            for constraint in popupView.constraints {
                if constraint.firstItem as? UIView == popupView && constraint.secondItem == nil && constraint.firstAttribute == .height && constraint.relation == .equal {
                    // 找到对应约束，修改约束值
                    constraint.constant = height
                    return
                }
            }
            // 没有找到对应约束，通过frame修改高度
            popupView.azl_set(height: height)
        }
    }
    /// option popup view的最小高度(默认为屏幕的一半)
    func overPopupViewMinHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height*0.5
    }
    /// option popup view的最大高度(默认为屏幕高度-状态栏高度)
    func overPopupViewMaxHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height
    }
}

/**
从下往上弹出的popup vc基类 

含有半屏显示和全屏显示两种状态(半屏和全屏只是一个相对的说法，具体显示的高度可以通过代理设置)
 */
open class AZLOverPopupViewController: UIViewController, UIGestureRecognizerDelegate {

    /// 拖动手势开始时的frame
    private var startFrame: CGRect = CGRect.zero
    
    /// overPopupView的相关代理
    public weak var overPopupDelegate: AZLOverPopupViewControllerDelegate?
    
    // 手势在viewDidload后有效
    /// 点击空白处取消界面的手势
    public var blankDismissTapGesture: UITapGestureRecognizer?
    /// 拖动手势
    public var popupPanGesture: UIPanGestureRecognizer?
    /// 消失所需拖动速度，拖动放开时速度比这快会触发页面消失
    public var dismissDragSpeed: Double = 480
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
        self.transitioningDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.blankDismissTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissTap(recognizer:)))
        
        // 背景添加消失点击
        self.view.addGestureRecognizer(self.blankDismissTapGesture!)
        
        // 添加拖动手势
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(containerViewPan(recognizer:)))
        self.view.addGestureRecognizer(panGesture)
        self.popupPanGesture = panGesture
    }
    
    /// 显示内容最大高度的样式
    public func showMaxPopupView() {
        if let overPopupView = self.overPopupDelegate?.overPopupView() {
            if let maxHeight = self.overPopupDelegate?.overPopupViewMaxHeight() {
                UIView.animate(withDuration: 0.275) { 
                    self.overPopupDelegate?.overPopupViewHeightShouldChange(height: maxHeight)
                    overPopupView.transform = CGAffineTransform.init(translationX: 0, y: 0)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    /// 显示内容最小高度的样式
    public func showMinPopupView() {
        if let overPopupView = self.overPopupDelegate?.overPopupView() {
            if let minHeight = self.overPopupDelegate?.overPopupViewMinHeight() {
                UIView.animate(withDuration: 0.275) { 
                    self.overPopupDelegate?.overPopupViewHeightShouldChange(height: minHeight)
                    overPopupView.transform = CGAffineTransform.init(translationX: 0, y: 0)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    /// 拖动内容view手势的回调
    @objc 
    func containerViewPan(recognizer: UIPanGestureRecognizer) {
        guard let maxHeight = self.overPopupDelegate?.overPopupViewMaxHeight() else {
            return
        }
        guard let minHeight = self.overPopupDelegate?.overPopupViewMinHeight() else {
            return
        }
    
        /// 拖动手势处理
        if let overPopupView = self.overPopupDelegate?.overPopupView() {
            let moveY = recognizer.translation(in: overPopupView).y
            let touchY = recognizer.location(in: self.view).y
            let moveProgress = touchY/self.view.bounds.size.height

            switch recognizer.state {
            case .began:    
                // 开始滑动：初始化UIPercentDrivenInteractiveTransition对象，并开启导航pop
                self.startFrame = overPopupView.frame
                
            case .changed:  
                // 滑动过程中，根据在屏幕上滑动的百分比更新状态
                var targetFrame = self.startFrame
                var offsetY: CGFloat = 0
                targetFrame.size.height -= moveY
                if targetFrame.size.height > maxHeight {
                    targetFrame.size.height = maxHeight
                } else if targetFrame.size.height < minHeight {
                    offsetY = minHeight-targetFrame.size.height
                    targetFrame.size.height = minHeight
                }
                self.overPopupDelegate?.overPopupViewHeightShouldChange(height: targetFrame.size.height)
                overPopupView.transform = CGAffineTransform.init(translationX: 0, y: offsetY)
                
            case .ended, .cancelled:    // 滑动结束或取消时，判断手指位置，滑动速度较快或快到底端时完成动画
                let velocity = recognizer.velocity(in: overPopupView).y
                if velocity > self.dismissDragSpeed || (moveProgress > 0.8 && velocity > -self.dismissDragSpeed/2) {
                    // 一定速度或到了靠底的位置，自动消失
                    self.dismiss(animated: true, completion: nil)
                    
                } else if (overPopupView.frame.size.height > (maxHeight+minHeight)/2.0 && velocity < self.dismissDragSpeed/2) || velocity < -self.dismissDragSpeed {
                    // 最大高度显示
                    self.showMaxPopupView()
                } else {
                    // 最小高度显示
                    self.showMinPopupView()
                }
                
            default: 
                break
            }
        }
    }
    
    /// 空白点击
    @objc
    func dismissTap(recognizer: UITapGestureRecognizer) {
        if let overPopupView = self.overPopupDelegate?.overPopupView() {
            let tapPoint = recognizer.location(in: overPopupView)
            if overPopupView.layer.contains(tapPoint) {
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}

// 过场动画设置
extension AZLOverPopupViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented != self {
            return nil
        }
        let animateTran = AZLOverPopupTransition()
        animateTran.tran = .present
        animateTran.containerView = self.overPopupDelegate?.overPopupView()
        return animateTran
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // over popup view会显示不正确
        if dismissed != self {
            return nil
        }
        
        let animateTran = AZLOverPopupTransition()
        animateTran.tran = .dismiss
        animateTran.containerView = self.overPopupDelegate?.overPopupView()
        return animateTran
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
