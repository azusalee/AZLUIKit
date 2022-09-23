//
//  ProcessViewController.swift
//  AZLUIKit_Example
//
//  Created by lizihong on 2022/9/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import AZLUIKit

class ProcessViewController: UIViewController {
    
    let processView = AZLProcessView.init(frame: CGRect.init(x: 30, y: 100, width: 250, height: 10))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        processView.processColor = UIColor.red
        processView.backgroundColor = UIColor.gray
        
        self.view.addSubview(self.processView)
    }

}
