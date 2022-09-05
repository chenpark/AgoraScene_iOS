//
//  VRRoomListCell.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/24.
//

import UIKit
import ZSwiftBaseLib

public final class VRRoomListCell: UITableViewCell {
    
    lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 20, y: 15, width: ScreenWidth-40, height: self.frame.height - 15)).image(UIImage("normal_room") ?? UIImage()).backgroundColor(.clear)
    }()
    
    lazy var accessSymbol: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: 0, width: 68, height: 24)).font(UIFont.systemFont(ofSize: 10, weight: .regular)).backgroundColor(.clear)
    }()
    
    lazy var roomName: UILabel = {
        UILabel(frame:CGRect(x: self.background.frame.width/2.0 - 10, y: 28, width: self.background.frame.width/2.0 - 20, height: 40)).font(UIFont.systemFont(ofSize: 15, weight: .medium)).textColor(.white).text("SDOIAJSIDOIASDJOIJSOIJDSDSADADSAD").numberOfLines(0)
    }()
    
    lazy var ownerName: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.roomName.frame.minX-10, y: self.roomName.frame.maxY+15, width: self.background.frame.width/2.0 - 20, height: 16)).isUserInteractionEnabled(false).font(UIFont.systemFont(ofSize: 10, weight: .regular))
    }()
    
    lazy var seenCount: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.roomName.frame.minX-10, y: self.background.frame.height-36, width: 55, height: 16)).isUserInteractionEnabled(false).font(UIFont.systemFont(ofSize: 10, weight: .regular))
    }()
    
    lazy var entryRoom: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.background.frame.width - 72, y: self.background.frame.height - 40, width: 56, height: 24)).font(UIFont.systemFont(ofSize: 12, weight: .semibold)).backgroundColor(.clear).title("Entry", .normal)
    }()
    
    lazy var entryBlur: UIView = {
        UIView(frame: self.entryRoom.frame).backgroundColor(UIColor(white: 1, alpha: 0.3)).cornerRadius(self.entryRoom.frame.height/2.0)
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.background)
        self.background.addSubViews([self.accessSymbol,self.roomName,self.ownerName,self.seenCount,self.entryBlur,self.entryRoom])
        self.setupViewsAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewsAttributes() {
        self.accessSymbol.set(image: UIImage("suo"), title: "Private", titlePosition: .right, additionalSpacing: 5, state: .normal)
        self.accessSymbol.setBackgroundImage(UIImage("securityType"), for: .normal)
        self.ownerName.contentHorizontalAlignment = .left
        self.ownerName.set(image: UIImage("testAvatar"), title: "  Test Name ", titlePosition: .right, additionalSpacing: 5, state: .normal)
        self.ownerName.titleLabel!.lineBreakMode(.byTruncatingTail)
        self.seenCount.set(image: UIImage("person_in_circle"), title: "  555", titlePosition: .right, additionalSpacing: 5, state: .normal)
        self.seenCount.contentHorizontalAlignment = .left
        self.seenCount.titleLabel!.lineBreakMode(.byTruncatingTail)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.background.frame = CGRect(x: 20, y: 15, width: ScreenWidth-40, height: self.frame.height - 15)
        self.accessSymbol.frame = CGRect(x: 0, y: 0, width: 68, height: 24)
        self.roomName.frame = CGRect(x: self.background.frame.width/2.0 - 10, y: 28, width: self.background.frame.width/2.0 - 20, height: 40)
        self.ownerName.frame = CGRect(x: self.roomName.frame.minX, y: self.roomName.frame.maxY+15, width: self.background.frame.width/2.0 - 20, height: 16)
        self.seenCount.frame = CGRect(x: self.roomName.frame.minX, y: self.background.frame.height-36, width: 55, height: 16)
        self.entryRoom.frame = CGRect(x: self.background.frame.width - 72, y: self.background.frame.height - 40, width: 56, height: 24)
        self.entryBlur.frame = self.entryRoom.frame
    }

}
