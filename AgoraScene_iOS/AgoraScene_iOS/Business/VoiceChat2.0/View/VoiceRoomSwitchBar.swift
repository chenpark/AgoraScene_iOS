//
//  VoiceRoomSwitchBar.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/9.
//

import UIKit
import ZSwiftBaseLib


@objc public enum VoiceRoomSwitchBarDirection: Int {
    case left = 1
    case right = 2
}

public class VoiceRoomSwitchBar: UIView {
    
    @objc public var selectAction: ((Int) -> ())?
    
    lazy var leftItem: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 20, y: 0, width: ScreenWidth/2.0-30, height: 24)).font(.systemFont(ofSize: 16, weight: .semibold)).textColor(.darkText, .normal).addTargetFor(self, action: #selector(selected(_:)), for: .touchUpInside).tag(11)
    }()
    
    lazy var rightItem: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth/2.0+10, y: 0, width: ScreenWidth/2.0-30, height: 24)).font(.systemFont(ofSize: 16, weight: .semibold)).textColor(.darkText, .normal).addTargetFor(self, action: #selector(selected(_:)), for: .touchUpInside).tag(12)
    }()
    
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.leftItem.center.x-12, y: self.leftItem.frame.maxY+5, width: 24, height: 3)).backgroundColor(UIColor(0x156EF3))
    }()
    
    let line = UIView().backgroundColor(UIColor(0xF2F2F2))

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect,titles: [String]) {
        self.init(frame: frame)
        self.line.frame = CGRect(x: 0, y: frame.height-1, width: frame.width, height: 1)
        if titles.count == 1 {
            self.addSubViews([self.leftItem,self.indicator,self.line])
            self.leftItem.frame = CGRect(x: 20, y: 0, width: ScreenWidth-40, height: 24)
            self.leftItem.setTitle(titles.first ?? "", for: .normal)
            self.indicator.frame = CGRect(x: self.frame.width/2.0-12, y: self.leftItem.frame.maxY+5, width: 24, height: 3)
        } else {
            self.addSubViews([self.leftItem,self.rightItem,self.indicator,self.line])
            self.leftItem.setTitle(titles.first ?? "", for: .normal)
            self.rightItem.setTitle(titles.last ?? "", for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selected(_ sender: UIButton) {
        self.moveTo(direction: sender.tag == 11 ? .left:.right)
        if self.selectAction != nil {
            self.selectAction!(sender.tag)
        }
    }
    
    @objc func moveTo(direction: VoiceRoomSwitchBarDirection) {
        let sender = direction == .left ? self.leftItem:self.rightItem
        var point = CGPoint(x: self.leftItem.center.x, y: self.indicator.center.y)
        if sender != self.leftItem {
            point = CGPoint(x: self.rightItem.center.x, y: self.indicator.center.y)
        }
        UIView.animate(withDuration: 0.3) {
            self.indicator.center = point
        }
    }
}
