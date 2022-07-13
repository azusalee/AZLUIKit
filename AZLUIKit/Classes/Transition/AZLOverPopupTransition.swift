//
//  AZLOverPopupTransition.swift
//  AZLUIKit
//
//  Created by lizihong on 2022/7/13.
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
    
    /// 出現動畫(从下向上出现)
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
    
    /// 消失動畫(从上向下消失)
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
