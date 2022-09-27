//
//  VoiceRoomIMManager.swift
//  Pods-VoiceRoomIMKit_Tests
//
//  Created by 朱继超 on 2022/9/1.
//

import Foundation
import AgoraChat

public let VoiceRoomGift = "chatroom_gift"
public let VoiceRoomPraise = "chatroom_praise"//like 点赞
public let VoiceRoomInviteSite = "chatroom_inviteSiteNotify"
public let VoiceRoomApplySite = "chatroom_applySiteNotify"
public let VoiceRoomDeclineApply = "chatroom_applyRefusedNotify"
public let VoiceRoomUpdateRobotVolume = "chatroom_updateRobotVolume"

@objc public protocol VoiceRoomIMDelegate: NSObjectProtocol {
    
    /// Description you'll call login api,when you receive this message
    /// - Parameter code: AgoraChatErrorCode
    func chatTokenDidExpire(code: AgoraChatErrorCode)
    /// Description you'll call login api,when you receive this message
    /// - Parameter code: AgoraChatErrorCode
    func chatTokenWillExpire(code: AgoraChatErrorCode)
    
    func receiveTextMessage(roomId: String,message: AgoraChatMessage)
    
    func receiveGift(roomId: String, meta: [String:String]?)
        
    func receiveApplySite(roomId: String, meta: [String:String]?)
    
    func receiveInviteSite(roomId: String, meta: [String:String]?)
    
    func refuseInvite(roomId: String, meta: [String:String]?)
    
    func userJoinedRoom(roomId: String, username: String)
    
    func announcementChanged(roomId: String, content: String)
    
    func voiceRoomUpdateRobotVolume(roomId: String, volume: String)
    
    func userBeKicked(roomId: String, reason: AgoraChatroomBeKickedReason)
    
    func roomAttributesDidUpdated(roomId: String, attributeMap: [String : String]?, from fromId: String)
    
    func roomAttributesDidRemoved(roomId: String, attributes: [String]?, from fromId: String)
}

fileprivate let once = VoiceRoomIMManager()

@objc public class VoiceRoomIMManager:NSObject,AgoraChatManagerDelegate,AgoraChatroomManagerDelegate,AgoraChatClientDelegate {
    
    public var currentRoomId = ""
    
    @objc public static var shared: VoiceRoomIMManager? = once
    
    @objc public weak var delegate: VoiceRoomIMDelegate?
    
    @objc public func configIM(appkey: String) {
        let options = AgoraChatOptions(appkey: appkey.isEmpty ? "easemob-demo#easeim":appkey)
        options.enableConsoleLog = true
        options.isAutoLogin = false
//        options.setValue(false, forKeyPath: "enableDnsConfig")
//        options.setValue(6717, forKeyPath: "chatPort")
//        options.setValue("52.80.99.104", forKeyPath: "chatServer")
//        options.setValue("http://a1-test.easemob.com", forKeyPath: "restServer")
        AgoraChatClient.shared().initializeSDK(with: options)
    }
    
    @objc public func loginIM(userName: String,token: String,completion: @escaping (String,AgoraChatError?)->Void) {
        if AgoraChatClient.shared().isLoggedIn {
            completion(AgoraChatClient.shared().currentUsername ?? "",nil)
        } else {
            AgoraChatClient.shared().login(withUsername: userName, agoraToken: token, completion: completion)
        }
    }
    
    @objc public func addChatRoomListener() {
        AgoraChatClient.shared().add(self, delegateQueue: .main)
        AgoraChatClient.shared().chatManager?.add(self, delegateQueue: .main)
        AgoraChatClient.shared().roomManager?.add(self, delegateQueue: .main)
    }
    
    @objc public func removeListener() {
        AgoraChatClient.shared().roomManager?.remove(self)
        AgoraChatClient.shared().chatManager?.remove(self)
    }
    
    deinit {
        self.removeListener()
    }
}

public extension VoiceRoomIMManager {
    //MARK: - AgoraChatClientDelegate
    func tokenDidExpire(_ aErrorCode: AgoraChatErrorCode) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.chatTokenDidExpire(code:))) {
            self.delegate?.chatTokenDidExpire(code: aErrorCode)
        }
    }
    
    func tokenWillExpire(_ aErrorCode: AgoraChatErrorCode) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.chatTokenWillExpire(code:))) {
            self.delegate?.chatTokenWillExpire(code: aErrorCode)
        }
    }
    
    //MARK: - AgoraChatManagerDelegate
    func messagesDidReceive(_ aMessages: [AgoraChatMessage]) {
        for message in aMessages {
            if message.to != self.currentRoomId {
                continue
            }
            if message.body is AgoraChatTextMessageBody {
                if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.receiveTextMessage(roomId:message:))) {
                    self.delegate?.receiveTextMessage(roomId: self.currentRoomId, message: message)
                }
                continue
            }
            if let body = message.body as? AgoraChatCustomMessageBody {
                if self.delegate != nil {
                    switch body.event {
                    case VoiceRoomGift:
                        if self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.receiveGift(roomId:meta:))) {
                            self.delegate?.receiveGift(roomId: self.currentRoomId, meta: body.customExt)
                        }
                    case VoiceRoomInviteSite:
                        if self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.receiveInviteSite(roomId:meta:))) {
                            self.delegate?.receiveInviteSite(roomId: self.currentRoomId, meta: body.customExt)
                        }
                    case VoiceRoomApplySite:
                        if self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.receiveApplySite(roomId:meta:))) {
                            self.delegate?.receiveApplySite(roomId: self.currentRoomId, meta: body.customExt)
                        }
                    case VoiceRoomDeclineApply:
                        if self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.refuseInvite(roomId:meta:))) {
                            self.delegate?.refuseInvite(roomId: self.currentRoomId, meta: body.customExt)
                        }
                    case VoiceRoomUpdateRobotVolume:
                        if self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.voiceRoomUpdateRobotVolume(roomId:volume:))) {
                            self.delegate?.voiceRoomUpdateRobotVolume(roomId: self.currentRoomId, volume: body.customExt["volume"] ?? "")
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    //MARK: - AgoraChatroomManagerDelegate
    func didReceiveUserJoinedChatroom(_ aChatroom: AgoraChatroom, username aUsername: String) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.userJoinedRoom(roomId:username:))) {
            if let roomId = aChatroom.chatroomId,roomId == self.currentRoomId  {
                self.delegate?.userJoinedRoom(roomId: roomId, username: aUsername)
            }
        }
    }
    
    func chatroomAnnouncementDidUpdate(_ aChatroom: AgoraChatroom, announcement aAnnouncement: String?) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.announcementChanged(roomId:content:))) {
            if let roomId = aChatroom.chatroomId,let announcement = aAnnouncement,roomId == self.currentRoomId  {
                self.delegate?.announcementChanged(roomId: roomId, content: announcement)
            }
        }
    }
    
    func didDismiss(from aChatroom: AgoraChatroom, reason aReason: AgoraChatroomBeKickedReason) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.userBeKicked(roomId:reason:))) {
            if let roomId = aChatroom.chatroomId,roomId == self.currentRoomId  {
                self.delegate?.userBeKicked(roomId: roomId, reason: aReason)
            }
        }
        switch aReason {
        case .beRemoved,.destroyed:
            if let roomId = aChatroom.chatroomId,roomId == self.currentRoomId  {
                self.currentRoomId = ""
            }
        default:
            break
        }
        self.removeListener()
        AgoraChatClient.shared().logout(false)
    }
    
    func chatroomAttributesDidUpdated(_ roomId: String, attributeMap: [String : String]?, from fromId: String) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.roomAttributesDidUpdated(roomId:attributeMap:from:))),roomId == self.currentRoomId  {
            self.delegate?.roomAttributesDidUpdated(roomId: roomId, attributeMap: attributeMap, from: fromId)
        }
    }
    
    func chatroomAttributesDidRemoved(_ roomId: String, attributes: [String]?, from fromId: String) {
        if self.delegate != nil,self.delegate!.responds(to: #selector(VoiceRoomIMDelegate.roomAttributesDidRemoved(roomId:attributes:from:))),roomId == self.currentRoomId {
            self.delegate?.roomAttributesDidRemoved(roomId: roomId, attributes: attributes, from: fromId)
        }
    }
    
    //MARK: - Send
    @objc func sendMessage(roomId: String,text: String, ext: [AnyHashable : Any]?,completion: @escaping (AgoraChatMessage?,AgoraChatError?) -> (Void)) {
        let message = AgoraChatMessage(conversationID: roomId, body: AgoraChatTextMessageBody(text: text), ext: ext)
        message.chatType = .chatRoom
        AgoraChatClient.shared().chatManager?.send(message, progress: nil, completion: completion)
    }
    
    @objc func sendCustomMessage(roomId: String,event: String,customExt: [String:String],completion: @escaping (AgoraChatMessage?,AgoraChatError?) -> (Void)) {
        let message = AgoraChatMessage(conversationID: roomId, body: AgoraChatCustomMessageBody(event: event, customExt: customExt), ext: nil)
        message.chatType = .chatRoom
        AgoraChatClient.shared().chatManager?.send(message, progress: nil, completion: completion)
    }
    
    @objc func joinedChatRoom(roomId: String,completion: @escaping ((AgoraChatroom?,AgoraChatError?)->())) {
        AgoraChatClient.shared().roomManager?.joinChatroom(roomId, completion: { room, error in
            if error == nil,let id = room?.chatroomId {
                self.currentRoomId = id
            }
            completion(room,error)
        })
    }
    
    @objc func userQuitRoom(completion: ((AgoraChatError?)->())?) {
        AgoraChatClient.shared().roomManager?.leaveChatroom(self.currentRoomId, completion: { error in
            if error == nil {
                AgoraChatClient.shared().roomManager?.remove(self)
                AgoraChatClient.shared().chatManager?.remove(self)
                self.currentRoomId = ""
            }
            if completion != nil {
                completion!(error)
            }
        })
        self.removeListener()
        AgoraChatClient.shared().logout(false)
    }
    
}
