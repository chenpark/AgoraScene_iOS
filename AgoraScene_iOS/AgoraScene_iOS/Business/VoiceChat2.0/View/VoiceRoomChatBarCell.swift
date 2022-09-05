//
//  VoiceRoomChatBarCell.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomChatBarCell: UICollectionViewCell {
    
    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.cornerRadius(self.contentView.frame.height/2.0)
        self.icon.frame =  CGRect(x: 7, y: 7, width: self.contentView.frame.width-14, height: self.contentView.frame.height-14)
    }
    
}
