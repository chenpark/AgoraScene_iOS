//
//  VoiceRoomApplyAlert.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/9.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomApplyAlert: UIView {
    
    /// 30 is cancel,other is confirm
    @objc public var actionEvents: ((Int)->())?
    
    lazy var header: VoiceRoomAlertContainer = {
        VoiceRoomAlertContainer(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 60))
    }()
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 20, y: self.header.frame.maxY, width: self.frame.width-40, height: 20)).font(.systemFont(ofSize: 16, weight: .semibold)).textAlignment(.center).textColor(.darkText)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 28, y: self.content.frame.maxY + 35, width: (self.frame.width-78)/2.0, height: 40)).cornerRadius(20).backgroundColor(UIColor(0xEFF4FF)).textColor(UIColor(0x756E98), .normal).title(LanguageManager.localValue(key: "Cancel"), .normal).font(.systemFont(ofSize: 16, weight: .semibold)).tag(30).addTargetFor(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }()
    
    lazy var confirm: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.cancel.frame.maxX+22, y: self.content.frame.maxY + 35, width: (self.frame.width-78)/2.0, height: 40)).cornerRadius(20).backgroundColor(UIColor(0xEFF4FF)).textColor(.white, .normal).title(LanguageManager.localValue(key: "Confirm"), .normal).font(.systemFont(ofSize: 16, weight: .semibold)).setGradient([UIColor(0x0B8AF2),UIColor(0x2753FF)], [CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)]).tag(31).addTargetFor(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(frame: CGRect, content: String,cancel tips: String,confirm text: String) {
        self.init(frame: frame)
        self.addSubViews([self.header,self.content,self.cancel,self.confirm])
        self.content.text(LanguageManager.localValue(key: content))
        self.cancel.setTitle(LanguageManager.localValue(key: tips), for: .normal)
        self.confirm.setTitle(LanguageManager.localValue(key: text), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        if self.actionEvents != nil {
            self.actionEvents!(sender.tag)
        }
    }
}


public class VoiceRoomCancelAlert: UIView {
    
    @objc public var actionEvents: ((Int)->())?
    
    lazy var header: VoiceRoomAlertContainer = {
        VoiceRoomAlertContainer(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 60))
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 28, y: self.header.frame.maxY + 9, width: self.frame.width-56, height: 40)).cornerRadius(20).backgroundColor(UIColor(0xEFF4FF)).textColor(UIColor(0x756E98), .normal).title(LanguageManager.localValue(key: "Cancel Request"), .normal).font(.systemFont(ofSize: 16, weight: .semibold)).tag(30).addTargetFor(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }()
    

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.header,self.cancel])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        if self.actionEvents != nil {
            self.actionEvents!(sender.tag)
        }
    }
}


