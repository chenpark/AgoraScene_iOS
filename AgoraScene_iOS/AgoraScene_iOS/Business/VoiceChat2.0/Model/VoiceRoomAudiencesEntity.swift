//
//  VoiceRoomAudiencesEntity.swift
//  AgoraScene_iOS
//
//  Created by 朱继超 on 2022/9/18.
//

import Foundation
import KakaJSON

@objc public class VoiceRoomAudiencesEntity:NSObject,Convertible {
    
    var total: Int?
    
    var cursor: String?
    
    var members: [VRUser]?
    
    required public override init() {
        
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}
