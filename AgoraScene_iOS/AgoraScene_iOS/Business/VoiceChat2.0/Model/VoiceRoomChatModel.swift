//
//  VoiceRoomChatEntity.swift
//  VoiceRoomBaseUIKit-VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation
import ZSwiftBaseLib

@objcMembers open class VoiceRoomChatEntity:NSObject {
    var uid: String? = ""
    var userName: String? = ""
    var content: String? = ""
    var joined: Bool? = false
    var fullText: String? {
        ((self.userName ?? "") + (self.content ?? ""))
    }
    lazy var height: CGFloat? = {
        self.joined == false ? (self.fullText?.z.sizeWithText(font: .systemFont(ofSize: 13, weight: .regular), size: CGSize(width: chatViewWidth - 50, height: 9990.0)).height ?? 0)+35:40
    }()
    
    lazy var attributeContent: NSAttributedString? = {
        self.renderAttributeText()
    }()
}

extension VoiceRoomChatEntity {
    
    func renderAttributeText() -> NSAttributedString {
        if self.joined! == false {
            return NSAttributedString {
                AttributedText(self.userName!+" : ").foregroundColor(Color(0x8BB3FF)).font(.systemFont(ofSize: 13, weight: .regular))
                AttributedText(self.content!).foregroundColor(self.joined! == false ? Color.white:Color(0xFCF0B3)).font(.systemFont(ofSize: 13, weight: .regular))
            }
        } else {
            let attachment = NSTextAttachment()
            attachment.image = UIImage("shaking_hand")
            attachment.bounds = CGRect(x: 0, y: -4.5, width: 18, height: 18)
            let attributeText = NSMutableAttributedString {
                AttributedText(self.userName!).foregroundColor(Color(0x8BB3FF)).font(.systemFont(ofSize: 13, weight: .regular))
                Space()
                AttributedText("Joined").foregroundColor(self.joined! == false ? Color.white:Color(0xFCF0B3)).font(.systemFont(ofSize: 13, weight: .regular))
                Space()
            }
            attributeText.append(NSMutableAttributedString(attachment: attachment))
            return attributeText
        }
    }
    
}

