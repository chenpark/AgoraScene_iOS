//
//  VoiceRoomGiftCell.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomGiftCell: UITableViewCell {
    
    public var gift: VoiceRoomGiftEntity? {
        willSet {
            if newValue != nil {
                DispatchQueue.main.async { self.refresh(item: newValue!) }
            }
        }
    }
    
    lazy var container: UIView = {
        UIView(frame: CGRect(x: 0, y: 5, width: self.contentView.frame.width, height: self.contentView.frame.height - 5)).backgroundColor(.clear)
    }()
    
    lazy var avatar: UIImageView = {
        UIImageView(frame: CGRect(x: 5, y: 5, width: self.frame.width/5.0, height: self.frame.width/5.0)).contentMode(.scaleAspectFit)
    }()
    
    lazy var userName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+6, y: 8, width: self.frame.width/5.0*2-12, height: 15)).font(.systemFont(ofSize: 12, weight: .semibold))
    }()
    
    lazy var giftName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+6, y: self.userName.frame.maxY, width: self.frame.width/5.0*2-12, height: 15)).font(.systemFont(ofSize: 12, weight: .regular))
    }()
    
    lazy var giftIcon: UIImageView = {
        UIImageView(frame: CGRect(x: self.frame.width/5.0*3, y: 0, width: self.frame.width/5.0, height: self.frame.width/5.0)).contentMode(.scaleAspectFit).image(UIImage("heart")!)
    }()
    
    lazy var giftNumbers: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width/5.0*4+8, y: 10, width: self.frame.width/5.0-16, height: self.frame.height - 20)).font(.init(name: "RobotoNembersVF", size: 18)).textColor(.white)
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.container)
        self.container.addSubViews([self.avatar,self.userName,self.giftName,self.giftIcon,self.giftNumbers])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        print(self.contentView.frame)
        self.container.frame = CGRect(x: 0, y: 5, width: self.contentView.frame.width, height: self.contentView.frame.height - 5)
        self.container.cornerRadius(20).setGradient([UIColor(red: 0.05, green: 0, blue: 0.763, alpha: 0),UIColor(red: 0.708, green: 0.368, blue: 1, alpha: 1)], [CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)])
        self.avatar.frame = CGRect(x: 5, y: 5, width: self.contentView.frame.height - 15, height: self.contentView.frame.height - 15)
        self.avatar.cornerRadius((self.contentView.frame.height - 15)/2.0)
        self.userName.frame = CGRect(x: self.avatar.frame.maxX+6, y: 8, width: self.frame.width/5.0*2-12, height: 15)
        self.giftName.frame = CGRect(x: self.avatar.frame.maxX+6, y: self.contentView.frame.height-25, width: self.frame.width/5.0*2-12, height: 15)
        self.giftIcon.frame = CGRect(x: self.frame.width/5.0*3, y: 5, width: self.container.frame.height-10, height: self.container.frame.height-10)
        self.giftNumbers.frame = CGRect(x: self.giftIcon.frame.maxX + 5, y: 5, width: self.container.frame.width - self.giftIcon.frame.maxX - 5, height: self.container.frame.height - 5)
    }
    
    private func refresh(item: VoiceRoomGiftEntity) {
        self.avatar.image = item.avatar
        self.userName.text = item.userName
        self.giftName.text = item.gift_name
        self.giftIcon.image = UIImage("\(item.gift_id!)")
        self.giftNumbers.text = "X \(item.gift_count!)"
    }
    
}
