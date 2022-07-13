//
//  AZLHollowBackgroundView.swift
//  AZLUIKit
//
//  Created by lizihong on 2022/7/13.
//

import UIKit

/// 中心镂空背景view
public class AZLHollowBackgroundView: UIView {
    /// 画形状的layer
    var shapeLayer = CAShapeLayer.init()
    /// 中心镂空宽度
    var centerSize: CGFloat = 0
    /// 镂空中心
    var centerY: CGFloat = 0
    /// 镂空拐角corner
    var hollowCorner: CGFloat = 8
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
    }
    
    func updateLayout() {
        let corner: CGFloat = self.hollowCorner
        let height = self.bounds.size.height
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 0))
        let totalWidth = self.bounds.size.width
        path.addLine(to: CGPoint.init(x: (totalWidth-centerSize)/2-corner, y: 0))
        
        path.addArc(withCenter: CGPoint.init(x: (totalWidth-centerSize)/2-corner, y: corner), radius: corner, startAngle:-CGFloat.pi/2,  endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint.init(x: (totalWidth-centerSize)/2, y: centerY))
        
        path.addArc(withCenter: CGPoint.init(x: totalWidth/2, y: centerY), radius: centerSize/2, startAngle:-CGFloat.pi,  endAngle: 0, clockwise: false)
        
        path.addLine(to: CGPoint.init(x: (totalWidth+centerSize)/2, y: corner))

        path.addArc(withCenter: CGPoint.init(x: (totalWidth+centerSize)/2+corner, y: corner), radius: corner, startAngle:-CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: true)
        
        path.addLine(to: CGPoint.init(x: totalWidth, y: 0))
        path.addLine(to: CGPoint.init(x: totalWidth, y: height))
        path.addLine(to: CGPoint.init(x: 0, y: height))
        path.addLine(to: CGPoint.init(x: 0, y: 0))
        self.shapeLayer.frame = self.bounds
        self.shapeLayer.path = path.cgPath
        self.layer.mask = self.shapeLayer
    }
    
    /// 设置中心镂空
    public func setCenterHollow(centerSize: CGFloat, centerY: CGFloat, corner: CGFloat) {
        self.hollowCorner = corner
        self.centerSize = centerSize
        self.centerY = centerY
        self.updateLayout()
    }
}
