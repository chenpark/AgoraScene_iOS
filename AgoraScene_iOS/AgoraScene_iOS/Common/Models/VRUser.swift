//
//  VRUser.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/25.
//

import Foundation

@objcMembers open class VRUser:NSObject, Codable {
    var uid: String?
    var channel_id: String?
    var name: String?
    var portrait: String?
}
