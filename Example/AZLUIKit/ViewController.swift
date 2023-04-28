//
//  ViewController.swift
//  AZLUIKit
//
//  Created by azusalee on 08/18/2021.
//  Copyright (c) 2021 azusalee. All rights reserved.
//

import UIKit
import AZLUIKit

extension String: AZLPopupListItem {
    public var displayName: String { return self }
}

enum DemoType: Int, CaseIterable {
    case tab
    case overPopup
    case floatView
    case processView
    case popupList
    
    func title() -> String {
        switch self {
        case .tab:
            return "tab"
        case .overPopup:
            return "overPopup"
        
        case .floatView:
            return "floatView"
        case .processView:
            return "processView"
        case .popupList:
            return "popupList"
        }
    }
    
    func isPush() -> Bool {
        switch self {
        case .overPopup, .popupList:
            return false
        default:
            return true
        }
    }
    
    func demoVC() -> UIViewController {
        switch self {
        case .tab:
            return DemoTabViewController()
        case .overPopup:
            return DemoOverPopupViewController()
        case .floatView:
            return FloatViewController()
        case .processView:
            return ProcessViewController()
        case .popupList:
            let controller = AZLPopupListViewController<String>()
            controller.dataArray = ["item1", "item2", "item3"]
            controller.appearPoint = CGPoint.init(x: 200, y: 300)
            return controller
        }
    }
    
    func isAnimate() -> Bool {
        switch self {
        case .popupList:
            return false
            
        default:
            return true
        }
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let dataArray = DemoType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demoCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demoCell", for: indexPath)
        cell.textLabel?.text = self.dataArray[indexPath.row].title()
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let type = self.dataArray[indexPath.row]
        let controller = type.demoVC()
        if type.isPush() {
            self.navigationController?.pushViewController(controller, animated: type.isAnimate())
        } else {
            self.present(controller, animated: type.isAnimate(), completion: nil)
        }
        
    }
}

