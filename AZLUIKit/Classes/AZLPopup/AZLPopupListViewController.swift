//
//  AZLPopupListViewController.swift
//  AZLUIKit
//
//  Created by lizihong on 2023/4/27.
//

import UIKit
import SnapKit
import AZLExtendSwift

/// AZLPopupListViewController的数据
public protocol AZLPopupListItem: Equatable {
    /// 显示的名字
    var displayName: String { get }
}

/// 弹窗列表页，一般用于单选
/// 一个可以从指定位置弹出的popup列表
/// 必须用present的方法出来，并设置animate为false
public class AZLPopupListViewController<T: AZLPopupListItem>: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
    
    private let containerView = UIView()
    private var itemHeight: CGFloat = 32
    
    /// 选择的icon，如果需要可以传入
    public var selectIcon: UIImage?
    /// 出现的点，一般传入屏幕点击的位置
    public var appearPoint: CGPoint = .zero
    
    /// 列表数组
    public var dataArray: [T] = []
    /// 选中的项
    public var selectItem: T?
    /// 点击回调
    public var itemDidTap: ((T) -> Void)?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        let button = UIButton.init(frame: self.view.bounds)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.addTarget(self, action: #selector(viewDidTap), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(self.tableView)
        
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.black.cgColor;
        containerView.layer.shadowOffset = CGSizeMake(1, 1);
        containerView.layer.shadowOpacity = 0.6;
        containerView.clipsToBounds = false
        containerView.backgroundColor = .clear
        
        // 列表
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.layer.cornerRadius = 10
        self.tableView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        self.tableView.separatorInset = .zero
        self.tableView.backgroundColor = UIColor.white
        
        self.tableView.register(PopupListTableCell.self, forCellReuseIdentifier: "PopupListTableCell")
        
        let height = CGFloat(min(self.dataArray.count*Int(itemHeight), Int(UIScreen.main.bounds.height*0.66)))
        let width: CGFloat = 230
        
        let screenSize = UIScreen.main.bounds.size
        
        // 调整整个列表出现的frame，保证列表不会超出屏幕
        var originY = appearPoint.y
        var originX = appearPoint.x
        
        if height+appearPoint.y > screenSize.height-50 {
            originY = screenSize.height-50-height
        }
        
        if width+appearPoint.x > screenSize.width-16 {
            originX = screenSize.width-16-width
        }
        
        // 调整anchorPoint，把放大缩小效果以appearPoint的位置为锚点
        self.containerView.layer.anchorPoint = CGPoint.init(x: (appearPoint.x-originX)/width, y: (appearPoint.y-originY)/height)
        self.containerView.frame = CGRect.init(x: originX, y: originY, width: width, height: height)
        self.tableView.frame = self.containerView.bounds
        
        self.showAppearAnimate()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc
    private func viewDidTap(_ button: UIButton) {
        self.showDismissAnimate()
    }
    
    private func showAppearAnimate() {
        self.containerView.alpha = 0.1
        self.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
            UIView.animate(withDuration: 0.275) {
                self.containerView.alpha = 1
                self.containerView.transform = CGAffineTransformMakeScale(1, 1)
            }
        })
        
    }
    
    private func showDismissAnimate() {
        UIView.animate(withDuration: 0.275) {
            self.containerView.alpha = 0.1
            self.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        } completion: { flag in
            self.dismiss(animated: false)
        }
    }
    
    // MARK: ------- 此处开始为 tableView 相关的方法实现
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.itemHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.dataArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PopupListTableCell", for: indexPath) as? PopupListTableCell {
            cell.titleLabel.text = item.displayName
            cell.selectIcon.image = self.selectIcon
            cell.selectIcon.isHidden = self.selectItem != item
            return cell
        }
        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = self.dataArray[indexPath.row]
        self.itemDidTap?(item)
        self.showDismissAnimate()
    }
    
}

/// 用于 AZLPopupListViewController 的cell
class PopupListTableCell: UITableViewCell {
    let titleLabel = UILabel()
    let selectIcon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupUI() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.selectIcon)
        
        self.titleLabel.textColor = UIColor.azl_createColor(argbValue: 0xff333333)
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.5
        
        self.selectIcon.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.selectIcon.snp.right).offset(0)
            make.right.equalTo(-16)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
    }
    
}
