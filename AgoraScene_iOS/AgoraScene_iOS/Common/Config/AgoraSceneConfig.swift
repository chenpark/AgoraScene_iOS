//
//  AgoraSceneConfig.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/5.
//

import Foundation

public struct AgoraConfig {
    // agoraRtc id and token
    public static let rtcId: String = "a8c2093abe874f588c2048dec64e2972"
    public static let rtcToken: String? = nil
    //agoraChat id and token
    public static let chatId: String = ""
    public static let chatToken: String = ""
    
    private static let VMBaseUrl = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/meta/demo/fulldemochat"
    public static let CreateCommonRoom = "\(AgoraConfig.VMBaseUrl)/01CreateRoomCommonChatroom"
    public static let CreateSpatialRoom = "\(AgoraConfig.VMBaseUrl)/02CeateRoomSpaticalChatroom"
    
    public static let baseAlienMic: [String] = [
        "/CN/01-01-B-CN.wav",
        "/CN/01-02-R-CN.wav",
        "/CN/01-03-B&R-CN.wav",
        "/CN/01-04-B-CN.wav",
        "/CN/01-05-R-CN.wav",
        "/CN/01-06-B-CN.wav",
        "/CN/01-07-R-CN.wav",
        "/CN/01-08-B-CN.wav",
    ]
    
    public static let spatialAlienMic: [String] = [
        "/CN/02-01-B-CN.wav",
        "/CN/02-02-R-CN.wav",
        "/CN/02-03-B&R-CN.wav",
        "/CN/02-04-B-CN.wav",
        "/CN/02-05-R-CN.wav",
        "/CN/02-06-B-CN.wav",
        "/CN/02-07-R-CN.wav",
        "/CN/02-08-B-CN.wav",
        "/CN/02-09-R-CN.wav",
        "/CN/02-10-B-CN.wav",
        "/CN/02-11-R-CN.wav",
        "/CN/02-12-B-CN.wav",
        "/CN/02-13-R-CN.wav",
        "/CN/02-14-B-CN.wav",
        "/CN/02-15-R-CN.wav",
        "/CN/02-16-B-CN.wav",
        "/CN/02-17-R-CN.wav",
        "/CN/02-18-B-CN.wav",
    ]
}
