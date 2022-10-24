//
//  VoiceRoomViewController+IM.swift
//  AgoraScene_iOS
//
//  Created by 朱继超 on 2022/10/11.
//

import Foundation
import UIKit
import AgoraChat
import KakaJSON

//MARK: - VoiceRoomIMDelegate
extension VoiceRoomViewController: VoiceRoomIMDelegate {
    
    func memberLeave(roomId: String, userName: String) {
        let info = self.roomInfo
        let count: Int = info?.room?.member_count ?? 0
        info?.room?.member_count = count - 1
        self.roomInfo = info
    }
    
    func voiceRoomUpdateRobotVolume(roomId: String, volume: String) {
        roomInfo?.room?.robot_volume = UInt(volume)
    }
    
    
    func chatTokenDidExpire(code: AgoraChatErrorCode) {
        if code == .tokenExpire {
            self.reLogin()
        }
    }
    
    func chatTokenWillExpire(code: AgoraChatErrorCode) {
        if code == .tokeWillExpire {
            self.reLogin()
        }
    }
    
    func receiveTextMessage(roomId: String, message: AgoraChatMessage) {
        self.showMessage(message: message)
    }
    
    func receiveGift(roomId: String, meta: [String : String]?) {
        guard let dic = meta else { return }
        var giftList = self.view.viewWithTag(1111) as? VoiceRoomGiftView
        if giftList == nil {
            giftList = self.giftList()
            self.view.addSubview(giftList!)
        }
        giftList?.gifts.append(model(from: dic, VoiceRoomGiftEntity.self))
        giftList?.cellAnimation()
        if let id = meta?["gift_id"],id == "VoiceRoomGift9" {
            self.rocketAnimation()
        }
        requestRankList()
    }
    
    func receiveApplySite(roomId: String, meta: [String : String]?) {
        if VoiceRoomUserInfo.shared.user?.uid  ?? "" != roomInfo?.room?.owner?.uid ?? "" {
            return
        }
        self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: true)
    }
    
    func receiveInviteSite(roomId: String, meta: [String : String]?) {
        guard let map = meta?["user"] else { return }
        let user = model(from: map, VRUser.self)
        if VoiceRoomUserInfo.shared.user?.uid  ?? "" != user?.uid ?? "" {
            return
        }
        self.showInviteMicAlert()
    }
    
    func refuseInvite(roomId: String, meta: [String : String]?) {
        let user = model(from: meta ?? [:], VRUser.self)
        if VoiceRoomUserInfo.shared.user?.uid  ?? "" != user.uid ?? "" {
            return
        }
        self.chatBar.refresh(event: .handsUp, state: .selected, asCreator: true)
        self.view.makeToast("User \(user.name ?? "")"+NSLocalizedString("rejected Invitation", comment: ""),point: self.toastPoint, title: nil, image: nil, completion: nil)
    }
    
    func userJoinedRoom(roomId: String, username: String, ext: Dictionary<String,Any>?) {
        //更新用户人数
        if ext?.keys.contains("member_count") == true  {
            if let count: String = ext?["member_count"] as? String {
                let info = self.roomInfo
                info?.room?.member_count = Int(count)
                self.roomInfo = info
            }
        } else if ext?.keys.contains("click_count") == true  {
            if let count: String = ext?["click_count"] as? String {
                let info = self.roomInfo
                info?.room?.click_count = Int(count)
                self.roomInfo = info
            }
        }
        self.convertShowText(userName: username, content: LanguageManager.localValue(key: "Joined"),joined: true)
    }
    
    func announcementChanged(roomId: String, content: String) {
        self.view.makeToast("Voice room announcement changed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
        guard let _ = roomInfo?.room else {return}
        roomInfo?.room!.announcement = content
    }
    
    func userBeKicked(roomId: String, reason: AgoraChatroomBeKickedReason) {
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
        VoiceRoomIMManager.shared?.delegate = nil
        var message = ""
        switch reason {
        case .beRemoved: message = "you are removed by owner!"
        case .destroyed: message = "VoiceRoom was destroyed!"
        case .offline: message = "you are offline!"
        @unknown default:
            break
        }
        self.view.makeToast(message,point: self.toastPoint, title: nil, image: nil, completion: nil)
        if reason == .destroyed || reason == .beRemoved || reason == .offline {
            if reason == .destroyed {
                NotificationCenter.default.post(name: NSNotification.Name("refreshList"), object: nil)
            }
            self.didHeaderAction(with: .back)
            
        }
        
    }
    
    //    func roomAttributesDidUpdated(roomId: String, attributeMap: [String : String]?, from fromId: String) {
    //        guard let dic = getMicStatus(with: attributeMap) else {return}
    //        var index: Int = dic["index"] ?? 0
    //        let status: Int = dic["status"] ?? 0
    //        if index > 6 {index = 6}
    //        guard let mic: VRRoomMic = roomInfo?.mic_info?[index] else {return}
    //        let mic_info = mic
    //        mic_info.status = status
    //        if status == 5 || status == -2 {
    //            self.roomInfo?.room?.use_robot = status == 5
    //        }
    //        self.roomInfo?.mic_info?[index] = mic_info
    //        self.rtcView.micInfos = self.roomInfo?.mic_info
    //        Throttler.throttle(delay: 1) {
    //            self.requestRoomDetail()
    //        }
    //    }
    
    func roomAttributesDidUpdated(roomId: String, attributeMap: [String : String]?, from fromId: String) {
        updateMic(attributeMap)
    }
    
    func roomAttributesDidRemoved(roomId: String, attributes: [String]?, from fromId: String) {
        
    }
    
    private func updateMic(_ map: [String : String]?) {
        guard let mic_info = map else {return}
        print("map----\(mic_info)")
        let keys = mic_info.keys.map { $0 }
        print("---keys:\(keys.count)")
        for key in keys {
            let value: String = mic_info[key] ?? ""
            let mic_dic: [String: Any] = value.z.jsonToDictionary()
            let mic: VRRoomMic = model(from: mic_dic, type: VRRoomMic.self) as! VRRoomMic
            
            let status = mic.status
            let mic_index = mic.mic_index
            if !self.isOwner {
                self.refreshHandsUp(status: status)
                if mic_index == local_index && (status == -1 || status == 3 || status == 4){
                    local_index = nil
                }
            }

            if status == 5 || status == -2 {
                //刷新机器人
                self.roomInfo?.mic_info?[mic_index] = mic
                self.rtcView.updateAlien(mic.status)
            } else {
                //刷新普通用户
                if mic.member != nil {
                    mic.member?.mic_index = mic_index
                }
                self.roomInfo?.mic_info?[mic_index] = mic
                self.rtcView.updateUser(mic)
                if let user = mic.member {
                    if let uid = user.uid {
                        let local_uid = VoiceRoomUserInfo.shared.user?.uid
                        if uid == local_uid {
                            local_index = mic_index
                        }
                        //如果当前是0的状态  就设置成主播
                        self.rtckit.muteLocalAudioStream(mute: status != 0)
                        if !isOwner {
                            self.rtckit.setClientRole(role: status == 0 ? .owner : .audience)
                        }
                    }
                }
            }
        }
    }
    
    
    //    private func getMicStatus(with map: [String : String]?) -> Dictionary<String, Int>? {
    //        guard let mic_info = map else {return nil}
    //        var first: Dictionary<String, Int>? = Dictionary()
    //        for mic in mic_info {
    //            let key: String = mic.key
    //            let value = mic.value.z.jsonToDictionary()
    //            guard let status: Int = value["status"] as? Int else {return nil}
    //            first?["status"] = status
    //
    //            if key.contains("mic_") {
    //                if key.components(separatedBy: "mic_").count > 1 {
    //                    let index = key.components(separatedBy: "mic_")[1]
    //                    if let mic_index = Int(index) {
    //                       first?["index"] = mic_index
    //                       let uid = VoiceRoomUserInfo.shared.user?.uid
    //                        if !self.isOwner {
    //                            if value.keys.contains("status"),let status = value["status"] as? Int,status == -1 {
    //                                self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: false)
    //                            } else {
    //                                self.chatBar.refresh(event: .handsUp, state: .disable, asCreator: false)
    //                            }
    //                            if mic_index == local_index && (status == -1 || status == 3 || status == 4){
    //                                local_index = nil
    //                            }
    //                        }
    //                       if value.keys.contains("uid") {
    //                          if uid == value["uid"] as? String ?? "" {
    //                              local_index = mic_index
    //                              //如果当前是0的状态  就设置成主播
    //                              if isOwner {
    //                                  self.rtckit.muteLocalAudioStream(mute: status != 0)
    //                              } else {
    //                                  self.rtckit.muteLocalAudioStream(mute: status != 0)
    //                                  self.rtckit.setClientRole(role: status == 0 ? .owner : .audience)
    //                              }
    //
    //                          }
    //                       }
    //                    }
    //                    return first
    //                }
    //            }
    //        }
    //        return nil
    //    }
    
    func refreshHandsUp(status: Int) {
        if status == -1 {
            self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: false)
        } else {
            self.chatBar.refresh(event: .handsUp, state: .disable, asCreator: false)
        }
    }
    
    func sendTextMessage(text: String) {
        self.inputBar.endEditing(true)
        self.inputBar.inputField.text = ""
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        guard let userName = VoiceRoomUserInfo.shared.user?.name  else { return }
        self.showMessage(message: AgoraChatMessage(conversationID: roomId, body: AgoraChatTextMessageBody(text: text), ext: ["userName":VoiceRoomUserInfo.shared.user?.name ?? ""]))
        VoiceRoomIMManager.shared?.sendMessage(roomId: roomId, text: text,ext: ["userName":userName]) { message, error in
            if error == nil,message != nil {
            } else {
                self.view.makeToast("\(error?.errorDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    func reLogin() {
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":VoiceRoomUserInfo.shared.user?.portrait ?? self.userAvatar,"name":VoiceRoomUserInfo.shared.user?.name ?? ""],classType:VRUser.self) { [weak self] user, error in
            if error == nil {
                VoiceRoomUserInfo.shared.user = user
                VoiceRoomBusinessRequest.shared.userToken = user?.authorization ?? ""
                AgoraChatClient.shared().renewToken(user?.im_token ?? "")
            } else {
                self?.view.makeToast("\(error?.localizedDescription ?? "")",point: self?.toastPoint ?? .zero, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    func showMessage(message: AgoraChatMessage) {
        if let body = message.body as? AgoraChatTextMessageBody,let userName = message.ext?["userName"] as? String {
            self.convertShowText(userName: userName, content: body.text,joined: false)
        }
    }
    
    func convertShowText(userName: String,content: String,joined: Bool) {
        let dic = ["userName":userName,"content":content]
        self.chatView.messages?.append(self.chatView.getItem(dic: dic, join: joined))
        DispatchQueue.main.async {
            self.refreshChatView()
        }
    }
    
    @objc func refreshChatView() {
        self.chatView.chatView.reloadData()
        let row = (self.chatView.messages?.count ?? 0) - 1
        self.chatView.chatView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: true)
    }
    
    func gifts() -> [VoiceRoomGiftEntity] {
        var gifts = [VoiceRoomGiftEntity]()
        for dic in giftMap {
            gifts.append(model(from: dic, VoiceRoomGiftEntity.self))
        }
        return gifts
    }
}
