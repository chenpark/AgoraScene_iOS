//
//  VREmptyView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/26.
//

import UIKit
import ZSwiftBaseLib

public class VREmptyView: UIView {
    
    var emptyImage = UIImage("empty")
    
    lazy var image: UIImageView = {
        UIImageView(frame: CGRect(x: 62, y: self.frame.height-40, width: ScreenWidth - 124, height: (140/240.0)*(ScreenWidth-124))).contentMode(.scaleAspectFit).image(self.emptyImage!)
    }()
    
    lazy var text: UILabel = {
        UILabel(frame: CGRect(x: 20, y: self.image.frame.maxY+10, width: ScreenWidth - 40, height: 60)).textAlignment(.center).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x979CBB)).numberOfLines(0)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect,title: String,image: UIImage?) {
        self.init(frame: frame)
        if image != nil {
            self.emptyImage = image!
        }
        self.addSubViews([self.image,self.text])
        self.text.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
