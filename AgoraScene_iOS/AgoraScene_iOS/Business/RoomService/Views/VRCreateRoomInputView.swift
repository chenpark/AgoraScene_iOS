//
//  VRCreateRoomInputView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/25.
//

import UIKit
import ZSwiftBaseLib

public class VRCreateRoomInputView: UIView,UITextFieldDelegate {
    
    var code = ""
    
    var name = ""
    
    var action: (()->())?
    
    private let height = ((ScreenWidth-90-3*16)/4.0)*(53/60.0)
    
    private let codeMessage = LanguageManager.localValue(key: "Enter 4 Digit Password.")
    
    private let nameMessage = LanguageManager.localValue(key: "Please set a name.")
    
    private var offset = CGFloat(ScreenHeight < 812 ? 140:60)
    
    lazy var roomName: UILabel = {
        UILabel(frame: CGRect(x: 40, y: 0, width: 80, height: 20)).font(.systemFont(ofSize: 14, weight: .regular)).text(LanguageManager.localValue(key: "Room Name")).textColor(.darkText).backgroundColor(.clear)
    }()
    
    lazy var randomName: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth - 120, y: 0, width: 80, height: 20)).backgroundColor(.clear).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x3C4267), .normal)
    }()
    
    lazy var roomBackground: UIView = {
        UIView(frame: CGRect(x: 30, y: self.roomName.frame.maxY+10, width: ScreenWidth - 60, height: 50)).cornerRadius(25).backgroundColor(.white)
    }()
    
    lazy var roomNameField: UITextField = {
        UITextField(frame: CGRect(x: 45, y: self.roomName.frame.maxY+15, width: ScreenWidth - 90, height: 40)).placeholder(LanguageManager.localValue(key: "Set Room Name")).font(.systemFont(ofSize: 18, weight: .regular)).textColor(.darkText).delegate(self)
    }()
    
    lazy var roomEncryption: UILabel = {
        UILabel(frame: CGRect(x: self.roomName.frame.minX, y: self.roomBackground.frame.maxY+12, width: 150, height: 20)).font(.systemFont(ofSize: 14, weight: .regular)).textColor(.darkText).text(LanguageManager.localValue(key: "Room Encryption")).backgroundColor(.clear)
    }()
    
    lazy var publicChoice: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.roomEncryption.frame.minX, y: self.roomEncryption.frame.maxY + 12, width: 90, height: 32)).title(LanguageManager.localValue(key: "Public"), .normal).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x3C4267), .normal).backgroundColor(.clear).tag(21).addTargetFor(self, action: #selector(chooseEncryption(_:)), for: .touchUpInside)
    }()
    
    lazy var privateChoice: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.publicChoice.frame.maxX+20, y: self.roomEncryption.frame.maxY + 12, width: 90, height: 32)).title(LanguageManager.localValue(key: "Private"), .normal).font(.systemFont(ofSize: 14, weight: .regular)).textColor(UIColor(0x3C4267), .normal).backgroundColor(.clear).tag(22).addTargetFor(self, action: #selector(chooseEncryption(_:)), for: .touchUpInside)
    }()
    
    lazy var pinCode: VRVerifyCodeView = {
        VRVerifyCodeView(frame: CGRect(x: 0, y: self.publicChoice.frame.maxY + 15, width: ScreenWidth, height: self.height), codeNumbers: 4, space: 16, padding: 45)
    }()
    
    lazy var warnMessage: UILabel = {
        UILabel(frame: CGRect(x: self.publicChoice.frame.minX, y: self.pinCode.frame.maxY+12, width: ScreenWidth - 80, height: 20)).font(.systemFont(ofSize: 12, weight: .regular)).textColor(UIColor(0xFA396A)).text(self.codeMessage)
    }()
    
    lazy var create: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 30, y: self.frame.height - CGFloat(ZTabbarHeight), width: ScreenWidth - 60, height: 48)).cornerRadius(24).title(LanguageManager.localValue(key: "Next"), .normal).textColor(.white, .normal).font(.systemFont(ofSize: 16, weight: .semibold)).addTargetFor(self, action: #selector(createAction), for: .touchUpInside).setGradient([UIColor(0x219BFF),UIColor(0x345DFF)], [CGPoint(x: 0.25, y: 0.5),CGPoint(x: 0.75, y: 0.5)])
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.addSubViews([self.roomName,self.randomName,self.roomBackground,self.roomNameField,self.roomEncryption,self.publicChoice,self.privateChoice,self.pinCode,self.warnMessage,self.create])
        self.setupAttributes()
        self.pinCode.textValueChange = { [weak self] in
            self?.code = $0
            self?.hiddenWarning()
        }
        self.pinCode.inputFinish = { [weak self] in
            self?.code = $0
            self?.recover()
        }
    }
    
    private func stateImage(button: UIButton) {
        button.setImage(UIImage("selected"), for: .selected)
        button.setImage(UIImage("unselected"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension VRCreateRoomInputView {
    
    private func setupAttributes() {
        self.warnMessage.alpha = 0
        self.pinCode.alpha = 0
        self.randomName.set(image: UIImage("random"), title: "Random", titlePosition: .right, additionalSpacing: 5, state: .normal)
        self.stateImage(button: self.publicChoice)
        self.stateImage(button: self.privateChoice)
        self.publicChoice.titleEdgeInsets = UIEdgeInsets(top: self.publicChoice.titleEdgeInsets.top, left: 10, bottom: self.publicChoice.titleEdgeInsets.bottom, right: self.publicChoice.titleEdgeInsets.right)
        self.privateChoice.titleEdgeInsets(UIEdgeInsets(top: self.privateChoice.titleEdgeInsets.top, left: 10, bottom: self.privateChoice.titleEdgeInsets.bottom, right: self.privateChoice.titleEdgeInsets.right))
        self.publicChoice.isSelected = true
        self.publicChoice.contentHorizontalAlignment = .left
    }
    
    @objc func chooseEncryption(_ sender: UIButton) {
        if sender.tag == 21 {
            self.privateChoice.isSelected = false
            self.publicChoice.isSelected = true
            if self.pinCode.textFiled.isFirstResponder {
                self.recover()
                self.pinCode.textFiled.resignFirstResponder()
            }
        } else {
            self.privateChoice.isSelected = true
            self.publicChoice.isSelected = false
            self.roomNameField.resignFirstResponder()
            self.pinCode.textFiled.becomeFirstResponder()
            self.raise()
        }
        UIView.animate(withDuration: 0.3) {
            self.pinCode.alpha = self.publicChoice.isSelected ? 0:1
        }
    }
    
    private func recover() {
        UIView.animate(withDuration: 0.3) {
            self.superview?.center = CGPoint(x: self.superview!.center.x, y: self.superview!.center.y+self.offset)
        }
    }
    
    private func raise() {
        UIView.animate(withDuration: 0.3) {
            self.superview?.center = CGPoint(x: self.superview!.center.x, y: self.superview!.center.y-self.offset)
        }
    }
    
    @objc private func createAction() {
        if self.privateChoice.isSelected {
            if let name = self.roomNameField.text,!name.isEmpty,!self.code.isEmpty {
                if self.action != nil {
                    self.action!()
                }
            } else if self.code.isEmpty {
                self.showWarning(self.codeMessage)
            } else {
                self.showWarning(self.nameMessage)
            }
        } else {
            if let name = self.roomNameField.text,!name.isEmpty {
                if self.action != nil {
                    self.action!()
                }
            } else {
                self.showWarning(self.nameMessage)
            }
        }
    }
    
    private func showWarning(_ text: String) {
        self.warnMessage.text = text
        UIView.animate(withDuration: 0.3) {
            self.warnMessage.alpha = 1
        }
    }
    
    private func hiddenWarning() {
        UIView.animate(withDuration: 0.3) {
            self.warnMessage.alpha = 0
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.name = textField.text ?? ""
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text ?? "").isEmpty {
            self.showWarning(self.nameMessage)
        } else {
            self.hiddenWarning()
        }
        return true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.pinCode.textFiled.isFirstResponder {
            self.recover()
        }
        self.endEditing(true)
    }
}
