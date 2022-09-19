//
//  VRRoomAvatarCell.swift
//  AgoraScene_iOS
//
//  Created by 朱继超 on 2022/9/18.
//

import UIKit
import ZSwiftBaseLib

public class VRRoomAvatarCell: UICollectionViewCell {
    
    var item: VRAvatar? {
        didSet {
            DispatchQueue.main.async {
                self.refresh(item: self.item)
            }
        }
    }
    
    lazy var avatar: UIImageView = {
        UIImageView(frame: CGRect(x: 10, y: 10, width: self.frame.width-20, height: self.frame.height-20)).contentMode(.scaleAspectFill)
    }()
    
    lazy var symbol: UIImageView = {
        UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24)).contentMode(.scaleAspectFill).image(UIImage(named: "check 1")!)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubViews([self.avatar,self.symbol])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        self.avatar.frame =  CGRect(x: 10, y: 10, width: self.frame.width-20, height: self.frame.height-20)
//        let space = sqrt(pow(self.avatar.frame.width/2.0, 2)/2.0)
//        self.symbol.center = CGPoint(x: self.avatar.center.x+space, y: self.avatar.center.y+space)
//    }
    
    private func refresh(item: VRAvatar?) {
        if let item = item {
            self.avatar.image = UIImage(named: item.portrait)
            var rect = CGRect(x: 10, y: 10, width: self.frame.width-20, height: self.frame.height-20)
            self.symbol.isHidden = !item.selected
            if item.selected {
                rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                self.avatar.layerProperties(UIColor(0x009FFF), 3)
            } else {
                self.avatar.layerProperties(.white, 3)
            }
            self.avatar.cornerRadius(rect.width/2.0)
            self.avatar.frame = rect
            if item.selected {
                let space = sqrt(pow(rect.width/2.0, 2)/2.0)
                self.symbol.center = CGPoint(x: self.avatar.center.x+space, y: self.avatar.center.y+space)
            }
        }
    }
    
}

public class VRAvatar {
    public var portrait = ""
    public var selected = false
}