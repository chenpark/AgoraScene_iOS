//
//  VoiceRoomGifterCell.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/9.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomGifterCell: UITableViewCell {

    lazy var avatar: UIImageView = {
        UIImageView(frame: CGRect(x: 15, y: 12, width: 50, height: 50)).contentMode(.scaleAspectFit).cornerRadius(25).backgroundColor(.orange)
    }()
    
    lazy var userName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+9, y: self.avatar.center.y-8, width: self.contentView.frame.width-self.avatar.frame.maxX-95, height: 16)).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x333333)).text("UserName")
    }()
    
    lazy var total: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-75, y: self.avatar.center.y-15, width: 60, height: 30)).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x6C7192)).text("123")
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([self.avatar,self.userName,self.total])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.userName.frame = CGRect(x: self.avatar.frame.maxX+9, y: self.avatar.center.y-8, width: self.contentView.frame.width-self.avatar.frame.maxX-95, height: 16)
        self.total.frame = CGRect(x: self.contentView.frame.width-75, y: self.avatar.center.y-15, width: 60, height: 30)
    }

}
