//
//  AZLTabItem.swift
//  AZLUIKit
//
//  Created by lizihong on 2022/7/13.
//

import UIKit

/**
tabItem的模型
 */
public class AZLTabItem {
    
    /// 未选中时的图片
    public var image: UIImage?
    /// 选中时的图片
    public var selectedImage: UIImage?
    
    /// 未选中时的颜色
    public var color: UIColor?
    /// 选中时的颜色
    public var selectedColor: UIColor?
    
    /// 未选中时的字体
    public var font: UIFont?
    /// 选中时的字体
    public var selectedFont: UIFont?
    
    /// 显示的文字内容
    public var name: String?
    
    public init(name: String?, image: UIImage?, color: UIColor?, selectedColor: UIColor?, font: UIFont?) {
        self.name = name
        self.image = image
        self.color = color
        self.selectedColor = selectedColor
        self.font = font
    }

}
