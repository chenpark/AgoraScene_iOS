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
    
    private static let VMBaseUrl = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/meta/demo/fulldemochat/aisound"
    public static let CreateCommonRoom = "\(AgoraConfig.VMBaseUrl)/01CreateRoomCommonChatroom"
    public static let CreateSpatialRoom = "\(AgoraConfig.VMBaseUrl)/02CeateRoomSpaticalChatroom"
    public static let SetAINSIntroduce = "\(AgoraConfig.VMBaseUrl)/07AINSIntroduce"
    
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
    
    public static let HighAINSIntroduc: [String] = [
        "/CN/Share/07-01-R-CN.wav",
        "/CN/High/07-02-B-CN-High.wav",
        "/CN/High/07-03-R-CN-High.wav",
        "/CN/Share/07-04-B-CN.wav",
        "/CN/Share/07-05-R-CN.wav",
        "/CN/Share/07-06-B-CN.wav",
        "/CN/Share/07-07-R-CN.wav",
    ]
    
    public static let MediumAINSIntroduc: [String] = [
        "/CN/Share/07-01-R-CN.wav",
        "/CN/Medium/07-02-B-CN-Medium.wav",
        "/CN/Medium/07-03-R-CN-Medium.wav",
        "/CN/Share/07-04-B-CN.wav",
        "/CN/Share/07-05-R-CN.wav",
        "/CN/Share/07-06-B-CN.wav",
        "/CN/Share/07-07-R-CN.wav",
    ]
    
    public static let NoneAINSIntroduc: [String] = [
        "/CN/Share/07-01-R-CN.wav",
        "/CN/None/07-02-B-CN-None.wav",
        "/CN/None/07-03-R-CN-None.wav",
        "/CN/Share/07-04-B-CN.wav",
        "/CN/Share/07-05-R-CN.wav",
        "/CN/Share/07-06-B-CN.wav",
        "/CN/Share/07-07-R-CN.wav",
    ]
    
    public static let HighSound: [String] = [
        "\(AgoraConfig.VMBaseUrl)/08AINSTVSound/CN/High/08-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/09AINSKitchenSound/CN/High/09-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/10AINStreetSound/CN/High/10-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/11AINSRobotSound/CN/High/11-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/12AINSOfficeSound/CN/High/12-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/13AINSHomeSound/CN/High/13-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/14AINSConstructionSound/CN/High/14-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/15AINSAlertSound/CN/High/15-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/16AINSApplause/CN/High/16-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/17AINSWindSound/CN/High/17-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/18AINSMicPopFilter/CN/High/18-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/19AINSAudioFeedback/CN/High/19-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/20ANISMicrophoneFingerRubSound/CN/High/20-01-B-CN-High.wav",
        "\(AgoraConfig.VMBaseUrl)/21ANISScreenTapSound/CN/High/21-01-B-CN-High.wav",
    ]
    
    public static let NoneSound: [String] = [
        "\(AgoraConfig.VMBaseUrl)/08AINSTVSound/CN/None/08-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/09AINSKitchenSound/CN/None/09-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/10AINStreetSound/CN/None/10-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/11AINSRobotSound/CN/None/11-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/12AINSOfficeSound/CN/None/12-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/13AINSHomeSound/CN/None/13-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/14AINSConstructionSound/CN/None/14-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/15AINSAlertSound/CN/None/15-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/16AINSApplause/CN/None/16-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/17AINSWindSound/CN/None/17-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/18AINSMicPopFilter/CN/None/18-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/19AINSAudioFeedback/CN/None/19-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/20ANISMicrophoneFingerRubSound/CN/None/20-01-B-CN-None.wav",
        "\(AgoraConfig.VMBaseUrl)/21ANISScreenTapSound/CN/None/21-01-B-CN-None.wav",
    ]
}
