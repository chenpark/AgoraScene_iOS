//
//  VoiceRoomGiftEntity.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import Foundation

@objcMembers open class VoiceRoomGiftEntity: NSObject {
    var gift_id: String? = ""
    var gift_name: String? = ""
    var userName: String? = ""
    var avatar: UIImage? {
        UIImage(self.gift_id ?? "")
    }
    var gift_count: String? = "0"
}

