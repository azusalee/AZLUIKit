//
//  AZLProcessView.swift
//  AZLExtendSwift
//
//  Created by lizihong on 2021/10/15.
//

import UIKit

/// 进度条
public class AZLProcessView: UIView {
    
    /// 已完成部分的layer
    public var processLayer: CAShapeLayer?
    /// 位于百分比位的锚点视图
    var anchorView: UIView?
    
    /// 已完成部分颜色
    public var processColor: UIColor = UIColor.blue {
        didSet {
            self.processLayer?.strokeColor = processColor.cgColor
        }
    }
    
    private var _process: CGFloat = 0
    /// 完成度 0 ~ 1 (少于0按0处理，大于1按1处理)
    public var process: CGFloat {
        set {
            self._process = min(max(newValue, 0), 1)
            self.setNeedsLayout()
        }
        get {
            return self._process
        }
    }
    
    /// 完成度改变回调
    public var processDidChange: ((CGFloat) -> Void)?

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        let layer = CAShapeLayer.init()
        layer.frame = self.bounds
        self.processLayer = layer
        self.processLayer?.strokeColor = self.processColor.cgColor
        self.layer.addSublayer(layer)
        
        // 添加手势
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(viewDidTap(gesture:)))
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(viewDidTap(gesture:)))
        
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
    }
    
    @objc
    func viewDidTap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let value = point.x/self.bounds.size.width
        self.process = value
        self.processDidChange?(_process)
    }
    
    @objc
    func viewDidPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let point = gesture.location(in: self)
            let value = point.x/self.bounds.size.width
            self.process = value
            self.processDidChange?(_process)
        }
    }
    
    /// 设置锚点视图
    public func setAnchorView(view: UIView?) {
        self.anchorView?.removeFromSuperview()
        self.anchorView = view
        if let view = view {
            self.addSubview(view)
        }
        self.setNeedsLayout()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.processLayer?.frame = self.bounds
        var process = self.process
        process = max(process, 0)
        process = min(process, 1)
        
        self.anchorView?.center = CGPoint.init(x: self.bounds.size.width*process, y: self.bounds.size.height/2)
        if process == 0 {
            self.processLayer?.isHidden = true
            return
        }
        self.processLayer?.isHidden = false
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: self.bounds.height/2))
        path.addLine(to: CGPoint.init(x: self.bounds.width*process, y: self.bounds.height/2))
        self.processLayer?.path = path.cgPath
        self.processLayer?.lineWidth = self.bounds.height
    }

}
