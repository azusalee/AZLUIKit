//
//  AZLProcessView.swift
//  AZLExtendSwift
//
//  Created by lizihong on 2021/10/15.
//

import UIKit

public class AZLProcessView: UIView {
    
    /// 已完成部分的layer
    public var processLayer: CAShapeLayer?
    
    /// 已完成部分颜色
    public var processColor: UIColor = UIColor.blue {
        didSet {
            self.processLayer?.strokeColor = processColor.cgColor
        }
    }
    
    /// 完成度 0 ~ 1
    public var process: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }

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
    
    private func setup() {
        let layer = CAShapeLayer.init()
        layer.frame = self.bounds
        self.processLayer = layer
        self.layer.addSublayer(layer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.processLayer?.frame = self.bounds
        var process = self.process
        process = min(process, 0)
        process = max(process, 1)
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
