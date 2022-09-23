//
//  ViewController.swift
//  AZLUIKit
//
//  Created by azusalee on 08/18/2021.
//  Copyright (c) 2021 azusalee. All rights reserved.
//

import UIKit

enum DemoType: Int, CaseIterable {
    case tab
    case overPopup
    case floatView
    case processView
    
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
        }
    }
    
    func isPush() -> Bool {
        switch self {
        case .overPopup:
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
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            self.present(controller, animated: true, completion: nil)
        }
        
    }
}

