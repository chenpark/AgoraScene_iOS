//
//  VRRoomEntity.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/24.
//

import Foundation

@objcMembers open class VRRoomsEntity:NSObject, Codable {
    var total: Int? //总房间数量
    var cursor: String? //下一次请求房间列表的cursor
    var rooms: [VRRoomEntity]?//房间信息数组
}

@objcMembers open class VRRoomEntity:NSObject, Codable {
    var room_id: String? //房间id
    var channel_id: String? //agora rtc channel id
    var chat_room_id: String? //agora chat chatroom id
    var name: String? // 房间名称
    var owner: VRUser?
    var is_private: Bool? //是否为私密房间
    var type: Int? //房间类型， 0 ：普通房间，1:3D房间
    var created_at: UInt? //创建房间时间戳，单位毫秒
}
