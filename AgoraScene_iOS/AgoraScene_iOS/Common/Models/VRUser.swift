//
//  VRUser.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/25.
//

import Foundation
import KakaJSON

@objc open class VRUser:NSObject, Convertible {
    public var uid: String?
    public var chat_uid: String?
    public var channel_id: String?
    public var name: String?
    public var portrait: String?
    public var authorization: String?
    public var im_token: String?
    public var invited = false
    public var amount: Int?
    public var rtc_uid: String?
    
    required public override init() {
        
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}

@objc open class VoiceRoomUserInfo: NSObject {
    
    public static let shared = VoiceRoomUserInfo()
    
    public var user: VRUser?
    
}
