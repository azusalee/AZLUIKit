//
//  AZLTabView.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/17.
//

import UIKit

/**
tabView基类
 */
public class AZLTabView: UIView {
    
    /// itemView被点击时的回调
    public var itemShouldSelectBlock: ((_ index:Int) -> Bool)?

    /// 当前选中索引
    var selectedIndex: Int = 0
    
    /// 设置当前选中itemView
    public func select(index: Int) {
        self.selectedIndex = index
    }
    
    /// 获取当前选中的Index
    public func getSelectIndex() -> Int {
        return self.selectedIndex
    }
    
}
