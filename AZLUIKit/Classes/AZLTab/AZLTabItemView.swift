//
//  AZLTabItemView.swift
//  TaskTimer
//
//  Created by lizihong on 2021/8/17.
//

import UIKit

open class AZLBaseTabItemView: UIView {
    open func updateUI(isSelected:Bool) {
        // 继承重写
    }
}

public class AZLTabItemView: AZLBaseTabItemView {

    public var normalImage:UIImage?
    public var selectedImage:UIImage?
    
    public var normalColor:UIColor?
    public var seletedColor:UIColor?
    
    public var normalFont:UIFont?
    public var selectedFont:UIFont?
    
    public var nameString:String?
    
    private var nameLabel:UILabel?
    private var imageView:UIImageView?
    
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
    
    func setup() {
        self.imageView = UIImageView.init(frame: self.bounds)
        self.imageView?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        self.nameLabel = UILabel.init(frame: self.bounds)
        self.nameLabel?.textAlignment = .center
        self.nameLabel?.numberOfLines = 2
        self.nameLabel?.autoresizingMask = [.flexibleWidth]
        
        self.addSubview(self.imageView!)
        self.addSubview(self.nameLabel!)
    }
    
    public override func updateUI(isSelected: Bool) {
        if isSelected {
            if let image = self.selectedImage {
                self.imageView?.image = image
                self.imageView?.frame = CGRect.init(x: (self.bounds.size.width-image.size.width)/2, y: 0, width: image.size.width, height: image.size.height)
            }else{
                self.imageView?.image = nil
                self.imageView?.isHidden = true
            }
            self.nameLabel?.textColor = self.seletedColor
            self.nameLabel?.font = self.selectedFont
        }else{
            if let image = self.normalImage {
                self.imageView?.image = image
                self.imageView?.frame = CGRect.init(x: (self.bounds.size.width-image.size.width)/2, y: 0, width: image.size.width, height: image.size.height)
            }else{
                self.imageView?.image = nil
                self.imageView?.isHidden = true
            }
            self.nameLabel?.textColor = self.normalColor
            self.nameLabel?.font = self.normalFont
        }
        
        self.nameLabel?.text = self.nameString
        
        let fixHeight = self.nameLabel?.sizeThatFits(CGSize.init(width: self.bounds.size.width, height: CGFloat(MAXFLOAT))).height ?? 0
        
        if self.imageView?.isHidden == false {
            self.nameLabel?.frame = CGRect.init(x: 0, y: self.imageView!.frame.origin.y+self.imageView!.frame.size.height+4, width: self.bounds.size.width, height: fixHeight)
        }else{
            self.nameLabel?.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: fixHeight)
        }
    }

}
