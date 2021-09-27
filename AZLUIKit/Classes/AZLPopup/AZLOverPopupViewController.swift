//
//  KSFullOverViewController.swift
//  KSUser
//
//  Created by lizihong on 2020/3/20.
//  Copyright © 2020 KS. All rights reserved.
//

import UIKit

/// 从下至上的过度动画
public class AZLOverPopupTransition: NSObject {
    public enum Transition {
        /// 出現
        case present
        /// 消失
        case dismiss
    }
    
    /// 轉場動畫類型
    public var tran: Transition = .present
    /// 動畫時長
    static let duration = 0.275
    /// 容器view(需要做彈出動畫效果的view)
    public weak var containerView: UIView?
    
    /// 開始背景色
    public var startBackgroundColor: UIColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.0)
    /// 結束背景色
    public var endBackgroundColor: UIColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
    
    /// 出現動畫
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toVC: UIViewController = transitionContext.viewController(forKey: .to) {
            if let containerView = self.containerView {
                toVC.view.backgroundColor = self.startBackgroundColor
                containerView.transform = CGAffineTransform.init(translationX: 0, y: UIScreen.main.bounds.size.height)
                UIView.animate(withDuration: AZLOverPopupTransition.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    containerView.transform = CGAffineTransform.init(translationX: 0, y: 0)
                    toVC.view.backgroundColor = self.endBackgroundColor
                }) { (_) in
                    transitionContext.completeTransition(true)
                }
            }
            transitionContext.containerView.addSubview(toVC.view)
        }
    }
    
    /// 消失動畫
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC: UIViewController = transitionContext.viewController(forKey: .from) {
            if let containerView = self.containerView {
                fromVC.view.backgroundColor = self.endBackgroundColor
                //containerView.transform = CGAffineTransform.init(translationX: 0, y: 0)
                UIView.animate(withDuration: AZLOverPopupTransition.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    containerView.transform = CGAffineTransform.init(translationX: 0, y: UIScreen.main.bounds.size.height)
                    fromVC.view.backgroundColor = self.startBackgroundColor
                }) { (_) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
            transitionContext.containerView.addSubview(fromVC.view)
        }
    }
}

extension AZLOverPopupTransition: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AZLOverPopupTransition.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch self.tran {
        case .present:
            presentTransition(transitionContext: transitionContext)
        case .dismiss:
            dismissTransition(transitionContext: transitionContext)
        }
    }
}

public protocol AZLOverPopupViewControllerDelegate: NSObjectProtocol {
    
    /// require 返回需要从下往上出现的view
    func overPopupView() -> UIView?
    
    /// option 主要内容view高度将要变化的回调
    func overPopupViewHeightShouldChange(height: CGFloat)
    /// option popup view的最小高度(默认为屏幕的一半)
    func overPopupViewMinHeight() -> CGFloat
    /// option popup view的最大高度(默认为屏幕高度-状态栏高度)
    func overPopupViewMaxHeight() -> CGFloat
    
}

extension AZLOverPopupViewControllerDelegate {
    /// 
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

open class AZLOverPopupViewController: UIViewController, UIGestureRecognizerDelegate {

    private var transitionPercent: UIPercentDrivenInteractiveTransition?
    /// 拖动手势开始时的frame
    private var startFrame: CGRect = CGRect.zero
    
    /// overPopupView的相关代理
    public weak var overPopupDelegate: AZLOverPopupViewControllerDelegate?
    /// 点击空白处取消界面的手势
    public var blankDismissTapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissTap(recognizer:)))
    
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
        
        //self.fullOverContainerView()?.backgroundColor = UIColor.ks_color(colorValue: .black1)
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        // 背景添加消失点击
        self.view.addGestureRecognizer(self.blankDismissTapGesture)
        
        // 添加拖动手势
        if let overPopupView = self.overPopupDelegate?.overPopupView() {
            self.addPan(inView: overPopupView)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    // 添加手势
    public func addPan(inView: UIView) {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(containerViewPan(recognizer:)))
        inView.addGestureRecognizer(gesture)

    }
    
    public func addTap(inView: UIView) {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissTap(recognizer:)))
        gesture.delegate = self
        inView.addGestureRecognizer(gesture)

    }

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
            var progress = recognizer.translation(in: overPopupView).y/UIScreen.main.bounds.size.height
            let moveY = recognizer.translation(in: overPopupView).y
            let moveProgress = moveY/overPopupView.bounds.size.height
            progress = min(1.0, max(0.0, progress))
            
            switch recognizer.state {
            case .began:    // 开始滑动：初始化UIPercentDrivenInteractiveTransition对象，并开启导航pop
                self.startFrame = overPopupView.frame
                //self.transitionPercent = UIPercentDrivenInteractiveTransition()
                //self.dismiss(animated: true, completion: nil)
                
            case .changed:   // 滑动过程中，根据在屏幕上滑动的百分比更新状态
               // self.transitionPercent?.update(progress)
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
                if velocity > 480 || (moveProgress > 0.75 && velocity > -160) {
                    // 一定速度或到了靠底的位置，自动消失
                    //self.transitionPercent = UIPercentDrivenInteractiveTransition()
                    //self.transitionPercent?.update(progress)
                    //self.transitionPercent?.finish()
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else if (overPopupView.frame.size.height > (maxHeight+minHeight)/2.0 && velocity < 160) || velocity < -320 {
                    // 最大高度显示
                    self.showMaxPopupView()
                } else {
                    // 最小高度显示
                    self.showMinPopupView()
                }
                
                self.transitionPercent = nil
            default: break
            }
        }
    }
    
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
        return self.transitionPercent
    }
}
