//
//  VoiceRoomViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import SnapKit
import ZSwiftBaseLib
import AgoraChat
import SVGAPlayer
import KakaJSON
import AgoraRtcKit

public enum ROLE_TYPE {
    case owner
    case audience
}


let giftMap = [["gift_id":"VoiceRoomGift1","gift_name":LanguageManager.localValue(key: "Sweet Heart"),"gift_price":"1","gift_count":"1","selected":true],["gift_id":"VoiceRoomGift2","gift_name":LanguageManager.localValue(key: "Flower"),"gift_price":"5","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift3","gift_name":LanguageManager.localValue(key: "Crystal Box"),"gift_price":"10","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift4","gift_name":LanguageManager.localValue(key: "Super Agora"),"gift_price":"20","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift5","gift_name":LanguageManager.localValue(key: "Star"),"gift_price":"50","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift6","gift_name":LanguageManager.localValue(key: "Lollipop"),"gift_price":"100","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift7","gift_name":LanguageManager.localValue(key: "Diamond"),"gift_price":"500","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift8","gift_name":LanguageManager.localValue(key: "Crown"),"gift_price":"1000","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift9","gift_name":LanguageManager.localValue(key: "Rocket"),"gift_price":"1500","gift_count":"1","selected":false]]

class VoiceRoomViewController: VRBaseViewController {
    
    lazy var toastPoint: CGPoint = {
        CGPoint(x: self.view.center.x, y: self.view.center.y+70)
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    var headerView: AgoraChatRoomHeaderView!
    var rtcView: AgoraChatRoomNormalRtcView!
    var sRtcView: AgoraChatRoom3DRtcView!
    
    @UserDefault("VoiceRoomUserAvatar", defaultValue: "") var userAvatar
    
    lazy var chatView: VoiceRoomChatView = {
        VoiceRoomChatView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - (ScreenHeight/667)*210 - 50, width: ScreenWidth, height:(ScreenHeight/667)*210))
    }()
    
    lazy var chatBar: VoiceRoomChatBar = {
        VoiceRoomChatBar(frame: CGRect(x: 0, y: ScreenHeight-CGFloat(ZBottombarHeight)-50, width: ScreenWidth, height: 50),style:self.roomInfo?.room?.type ?? 0 == 1 ? .spatialAudio:.normal)
    }()
    
    lazy var inputBar: VoiceRoomInputBar = {
        VoiceRoomInputBar(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 60)).backgroundColor(.white)
    }()
    
    var preView: VMPresentView!
    var noticeView: VMNoticeView!
    var isShowPreSentView: Bool = false
    var rtckit: ASRTCKit = ASRTCKit.getSharedInstance()
    var isOwner: Bool = false
    var ains_state: AINS_STATE = .mid
    var local_index: Int? = nil
    var alienCanPlay: Bool = true
    var vmType: VMMUSIC_TYPE = .social
    
    public var roomInfo: VRRoomInfo? {
        didSet {
            if let entity = roomInfo?.room {
                if headerView == nil {return}
                headerView.entity = entity
            }
            VoiceRoomUserInfo.shared.currentRoomOwner = self.roomInfo?.room?.owner
            if let mics = roomInfo?.mic_info {
                if let type = roomInfo?.room?.type {
                    if type == 0 && self.rtcView != nil {
                        self.rtcView.micInfos = mics
                    } else if type == 1 && self.sRtcView != nil {
                        
                    }
                }
            }
        }
    }
    
    convenience init(info: VRRoomInfo) {
        self.init()
        self.roomInfo = info
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = VoiceRoomUserInfo.shared.user else {return}
        guard let owner = self.roomInfo?.room?.owner else {return}
        guard let type = self.roomInfo?.room?.sound_effect else {return}
        isOwner = user.uid == owner.uid
        local_index = isOwner ? 0 : nil
        vmType = getSceneType(type)
        
        VoiceRoomIMManager.shared?.delegate = self
        VoiceRoomIMManager.shared?.addChatRoomListener()
        //获取房间详情
        requestRoomDetail()
        
        //加载RTC+IM
        loadKit()
        //布局UI
        layoutUI()
        //处理底部事件
        self.charBarEvents()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigation.isHidden = false
    }
    
    deinit {
        leaveRoom()
        VoiceRoomUserInfo.shared.currentRoomOwner = nil
        VoiceRoomIMManager.shared?.delegate = nil
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
    }
    
}

extension VoiceRoomViewController {
    //加载RTC
    func loadKit() {
        
        guard let channel_id = self.roomInfo?.room?.channel_id else {return}
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        guard let rtcUid = VoiceRoomUserInfo.shared.user?.rtc_uid else {return}
        rtckit.setClientRole(role: isOwner ? .owner : .audience)
        rtckit.delegate = self
        
        var rtcJoinSuccess: Bool = false
        var IMJoinSuccess: Bool = false
        
        let VMGroup = DispatchGroup()
        let VMQueue = DispatchQueue(label: "com.agora.vm.www")
        
        VMGroup.enter()
        VMQueue.async {[weak self] in
            rtcJoinSuccess = self?.rtckit.joinVoicRoomWith(with: "\(channel_id)", rtcUid: Int(rtcUid) ?? 0, type: self?.vmType ?? .social) == 0
            VMGroup.leave()
        }
        
        VMGroup.enter()
        VMQueue.async {[weak self] in
            
            VoiceRoomIMManager.shared?.joinedChatRoom(roomId: roomId, completion: {[weak self] room, error in
                guard let `self` = self else { return }
                if error == nil {
                    IMJoinSuccess = true
                    VMGroup.leave()
                    self.view.makeToast("join IM success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                } else {
                    self.view.makeToast("\(error?.errorDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
                    IMJoinSuccess = false
                    VMGroup.leave()
                    self.view.makeToast("join IM failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            })
            
        }
        
        VMGroup.notify(queue: VMQueue){[weak self] in
            DispatchQueue.main.async {
                let joinSuccess = rtcJoinSuccess && IMJoinSuccess
                //上传登陆信息到服务器
                self?.uploadStatus(status: joinSuccess)
            }
        }
        
    }
    
    func getSceneType(_ type: String) -> VMMUSIC_TYPE {
        switch type {
        case LanguageManager.localValue(key: "Karaoke"):
            return .ktv
        case LanguageManager.localValue(key: "Gaming Buddy"):
            return .game
        case LanguageManager.localValue(key: "Professional Bodcaster"):
            return .anchor
        default:
            return .social
        }
    }
    
    //加入房间获取房间详情
    func requestRoomDetail() {
        
        //如果不是房主。需要主动获取房间详情
        guard let room_id = self.roomInfo?.room?.room_id else {return}
        VoiceRoomBusinessRequest.shared.sendGETRequest(api: .fetchRoomInfo(roomId: room_id), params: [:], classType: VRRoomInfo.self) {[weak self] room, error in
            if error == nil {
                guard let info = room else { return }
                self?.roomInfo = info
            } else {
                self?.view.makeToast("\(error?.localizedDescription ?? "")",point: self?.toastPoint ?? .zero, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    func layoutUI() {
        
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "lbg")
        self.view.addSubview(bgImgView)
        
        headerView = AgoraChatRoomHeaderView()
        headerView.completeBlock = {[weak self] action in
            self?.didHeaderAction(with: action)
        }
        self.view.addSubview(headerView)
        
        self.sRtcView = AgoraChatRoom3DRtcView()
        self.view.addSubview(self.sRtcView)
        
        self.rtcView = AgoraChatRoomNormalRtcView()
        self.rtcView.clickBlock = {[weak self] (type, tag) in
            self?.didRtcAction(with: type, tag: tag)
        }
        self.view.addSubview(self.rtcView)
        
        if let entity = self.roomInfo?.room {
            self.sRtcView.isHidden = entity.type == 0
            self.rtcView.isHidden = entity.type == 1
            headerView.entity = entity
        }
        
        bgImgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.view);
        }
        
        let isHairScreen = SwiftyFitsize.isFullScreen
        self.headerView.snp.makeConstraints { make in
            make.left.top.right.equalTo(self.view);
            make.height.equalTo(isHairScreen ? 140~ : 140~ - 25);
        }
        
        self.sRtcView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(550~);
        }
        
        self.rtcView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(240~);
        }
        if self.roomInfo?.room?.type ?? 0 == 1 {
            self.view.addSubViews([self.chatBar])
            self.inputBar.isHidden = true
        } else {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(resignKeyboard))
            pan.minimumNumberOfTouches = 1
            self.rtcView.addGestureRecognizer(pan)
            self.view.addSubViews([self.chatView,self.giftList(),self.chatBar,self.inputBar])
            self.inputBar.isHidden = true
        }
        self.chatView.messages?.append(self.startMessage())
    }
    
    func giftList() -> VoiceRoomGiftView {
        VoiceRoomGiftView(frame: CGRect(x: 10, y: self.chatView.frame.minY - (ScreenWidth/9.0*2), width: ScreenWidth/3.0*2, height: ScreenWidth/9.0*1.8)).backgroundColor(.clear).tag(1111)
    }
    
    func startMessage() -> VoiceRoomChatEntity {
        VoiceRoomUserInfo.shared.currentRoomOwner = self.roomInfo?.room?.owner
        let entity = VoiceRoomChatEntity()
        entity.userName = self.roomInfo?.room?.owner?.name
        entity.content = "Welcome to Agora Chat Room! Sexual or violent content is strictly prohibited. Speak kindly, friendship muchly."
        entity.attributeContent = entity.attributeContent
        entity.uid = self.roomInfo?.room?.owner?.uid
        entity.width = entity.width
        entity.height = entity.height
        return entity
    }
    
    func uploadStatus( status: Bool) {
        guard let roomId = self.roomInfo?.room?.room_id  else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .joinRoom(roomId: roomId), params: [:]) { dic, error in
            if let result = dic?["result"] as? Bool,error == nil,result {
                self.view.makeToast("Joined successful!",point: self.toastPoint, title: nil, image: nil, completion: nil)
            } else {
                self.didHeaderAction(with: .back)
            }
        }
    }
    
    @objc func resignKeyboard() {
        self.inputBar.hiddenInputBar()
    }
    
    func didHeaderAction(with action: HEADER_ACTION) {
        if action == .back {
            self.notifySeverLeave()
            self.rtckit.leaveChannel()
            
            //giveupStage()
            cancelRequestSpeak(index: nil)
            if self.isOwner {
                if let vc = self.navigationController?.viewControllers.filter({ $0 is VRRoomsViewController
                }).first {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else if action == .notice {
            showNoticeView(with: self.isOwner ? .owner : .audience)
        } else if action == .rank {
            //展示土豪榜
            self.showUsers()
        } else if action == .soundClick {
            showSoundView()
        }
    }
    
    func didRtcAction(with type: AgoraChatRoomBaseUserCellType, tag: Int) {
        if type == .AgoraChatRoomBaseUserCellTypeAdd {
            //这里需要区分观众与房主
            if isOwner {
                showApplyAlert(tag - 200)
            } else {
                if local_index != nil {
                    changeMic(from: local_index!, to: tag - 200)
                } else {
                    userApplyAlert(tag - 200)
                }
            }
        } else if type == .AgoraChatRoomBaseUserCellTypeAlienActive {
            showActiveAlienView(true)
        } else if type == .AgoraChatRoomBaseUserCellTypeAlienNonActive {
            showActiveAlienView(false)
        } else if type == .AgoraChatRoomBaseUserCellTypeNormalUser {
            //用户下麦或者mute自己
            if tag - 200 == local_index {
                showMuteView(with: tag - 200)
            } else {
                if isOwner {
                    showApplyAlert(tag - 200)
                }
            }
        } else if type == .AgoraChatRoomBaseUserCellTypeLock {
            if isOwner {
                showApplyAlert(tag - 200)
            } else {
                //用户下麦或者mute自己
            }
        } else if type == .AgoraChatRoomBaseUserCellTypeMute {
            if tag - 200 == local_index {
                showMuteView(with: tag - 200)
            } else {
                if isOwner {
                    showApplyAlert(tag - 200)
                }
            }
        } else if type == .AgoraChatRoomBaseUserCellTypeMuteAndLock {
            if isOwner {
                showApplyAlert(tag - 200)
            } else {
                //用户下麦或者mute自己
            }
        } else if type == .AgoraChatRoomBaseUserCellTypeForbidden {
            if tag - 200 == local_index {
                showMuteView(with: tag - 200)
            } else {
                if isOwner {
                    showApplyAlert(tag - 200)
                }
            }
        }
    }
    
    func notifySeverLeave() {
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: roomId), params: [:]) { dic, error in
            if let result = dic?["result"] as? Bool,error == nil,result {
                debugPrint("result:\(result)")
            }
        }
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.inputBar.hiddenInputBar()
        if self.isShowPreSentView {
            UIView.animate(withDuration: 0.5, animations: {
                self.preView.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 450~)
            }) { _ in
                self.preView.removeFromSuperview()
                self.preView = nil
                self.sRtcView.isUserInteractionEnabled = true
                self.rtcView.isUserInteractionEnabled = true
                self.headerView.isUserInteractionEnabled = true
                self.isShowPreSentView = false
            }
        }
    }
    
    func showNoticeView(with role: ROLE_TYPE) {
        let noticeView = VMNoticeView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 220~))
        noticeView.roleType = role
        noticeView.noticeStr = roomInfo?.room?.announcement ?? ""
        noticeView.resBlock = {[weak self] (flag, str) in
            self?.dismiss(animated: true)
            guard let str = str else {return}
            //修改群公告
            self?.updateNotice(with: str)
        }
        let noticeStr = self.roomInfo?.room?.announcement ?? ""
        noticeView.noticeStr = noticeStr
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 220~)), custom: noticeView)
        self.presentViewController(vc)
    }
    
    func showSoundView() {
        guard let soundEffect = self.roomInfo?.room?.sound_effect else {return}
        let soundView = VMSoundView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 220~))
        soundView.soundEffect = soundEffect
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 220~)), custom: soundView)
        self.presentViewController(vc)
    }
    
    func showActiveAlienView(_ active: Bool) {
        if !isOwner {
            self.view.makeToast("只有房主才能操作agora机器人")
            return
        }
        let confirmView = VMConfirmView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 40~, height: 220~))
        var compent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth - 40~, height: 220~))
        compent.destination = .center
        let vc = VoiceRoomAlertViewController(compent: compent, custom: confirmView)
        confirmView.resBlock = {[weak self] (flag) in
            self?.dismiss(animated: true)
            if flag == false {return}
            self?.activeAlien(active)
        }
        self.presentViewController(vc)
    }
    
    func activeAlien(_ flag: Bool) {
        if isOwner == false {return}
        guard let roomId = roomInfo?.room?.room_id else {return}
        guard let mic: VRRoomMic = roomInfo?.mic_info![6] else {return}
        let params: Dictionary<String, Bool> = ["use_robot":flag]
        VoiceRoomBusinessRequest.shared.sendPUTRequest(api: .modifyRoomInfo(roomId: roomId), params: params) { map, error in
            if map != nil {
                //如果返回的结果为true 表示上麦成功
                if let result = map?["result"] as? Bool,error == nil,result {
                    if result == true {
                        print("激活机器人成功")
                        
                        if self.alienCanPlay {
                            self.rtckit.playMusic(with: .alien)
                        }
                        
                        var mic_info = mic
                        mic_info.status = flag == true ? 5 : -2
                        self.roomInfo?.room?.use_robot = flag
                        self.roomInfo?.mic_info![6] = mic_info
                        self.rtcView.micInfos = self.roomInfo?.mic_info
                    }
                } else {
                    print("激活机器人失败")
                }
            } else {
                
            }
        }
    }
    // announcement
    func updateNotice(with str: String) {
        guard let roomId = roomInfo?.room?.room_id else {return}
        let params: Dictionary<String, String> = ["announcement":str]
        VoiceRoomBusinessRequest.shared.sendPUTRequest(api: .modifyRoomInfo(roomId: roomId), params: params) { map, error in
            if map != nil {
                //如果返回的结果为true 表示上麦成功
                if let result = map?["result"] as? Bool,error == nil,result {
                    if result == true {
                        print("修改群公告成功")
                        self.roomInfo?.room?.announcement = str
                    }
                } else {
                    print("修改群公告失败")
                }
            } else {
                
            }
        }
    }
    
    func updateVolume(_ Vol: Int) {
        if isOwner == false {return}
        guard let roomId = roomInfo?.room?.room_id else {return}
        let params: Dictionary<String, Int> = ["robot_volume": Vol]
        VoiceRoomBusinessRequest.shared.sendPUTRequest(api: .modifyRoomInfo(roomId: roomId), params: params) { map, error in
            if map != nil {
                //如果返回的结果为true 表示上麦成功
                if let result = map?["result"] as? Bool,error == nil,result {
                    if result == true {
                        print("调节机器人音量成功")
                        guard let room = self.roomInfo?.room else {return}
                        var newRoom = room
                        newRoom.robot_volume = UInt(Vol)
                        self.roomInfo?.room = newRoom
                        self.rtckit.adjustAudioMixingPublishVolume(with: Vol)
                    }
                } else {
                    print("调节机器人音量失败")
                }
            } else {
                
            }
        }
    }
    
    //     func leaveRoom() {
    //        guard let roomId = roomInfo?.room?.room_id else {return}
    //        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: roomId), params: [:]) {[weak self] map, error in
    //            if map != nil {
    //                //如果返回的结果为true 表示上麦成功
    //                if let result = map?["result"] as? Bool,error == nil,result {
    //                    debugPrint("--- giveupStage :result:\(result)")
    //                    self?.requestRoomDetail()
    //                } else {
    //                    self?.view.makeToast("leaveRoom failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
    //                }
    //            } else {
    //
    //            }
    //        }
    //    }
    
    func getApplyList() {
        guard let roomId = roomInfo?.room?.room_id else {return}
        
    }
    
    
    func charBarEvents() {
        self.chatBar.raiseKeyboard = { [weak self] in
            self?.inputBar.isHidden = false
            self?.inputBar.inputField.becomeFirstResponder()
        }
        self.inputBar.sendClosure = { [weak self] in
            self?.sendTextMessage(text: $0)
        }
        self.chatBar.events = { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .eq: self.showEQView()
            case .mic: self.changeMicState()
            case .gift: self.showGiftAlert()
            case .handsUp: self.changeHandsUpState()
            default: break
            }
        }
    }
    
    
    //禁言指定麦位
    func mute(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .muteMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("mute success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                } else {
                    self.view.makeToast("mute failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //取消禁言指定麦位
    func unMute(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .unmuteMic(roomId: roomId, index: index), params: [:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("unmute success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                    self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: false)
                } else {
                    self.view.makeToast("unmute failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //踢用户下麦
    func kickoff(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
        let dic: Dictionary<String, Any> = [
            "uid":mic.member?.uid ?? 0,
            "mic_index": index
        ]
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .kickMic(roomId: roomId), params: dic) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("kickoff success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                } else {
                    self.view.makeToast("kickoff failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //锁麦
    func lock(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .lockMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("lock success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                } else {
                    self.view.makeToast("lock failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //取消锁麦
    func unLock(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .unlockMic(roomId: roomId, index: index), params: [:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("unLock success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                } else {
                    self.view.makeToast("unLock failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //下麦
    func leaveMic(with index: Int) {
        self.chatBar.refresh(event: .mic, state: .selected, asCreator: false)
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveMic(roomId: roomId, index: index), params: [:]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("leaveMic success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                    //                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
                    //                    var mic_info = mic
                    //                    mic_info.status = -1
                    //                    self.roomInfo?.mic_info![index] = mic_info
                    //                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("leaveMic failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //mute自己
    func muteLocal(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .closeMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.chatBar.refresh(event: .mic, state: .selected, asCreator: false)
                    self.view.makeToast("mute local success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                    //                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
                    //                    var mic_info = mic
                    //                    mic_info.status = 1
                    //                    self.roomInfo?.mic_info![index] = mic_info
                    //                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("unmute local failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    //unmute自己
    func unmuteLocal(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .cancelCloseMic(roomId: roomId, index: index), params: [:]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.chatBar.refresh(event: .mic, state: .unSelected, asCreator: false)
                    self.view.makeToast("unmuteLocal success!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                    //                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
                    //                    var mic_info = mic
                    //                    mic_info.status = 0
                    //                    self.roomInfo?.mic_info![index] = mic_info
                    //                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("unmuteLocal failed!",point: self.toastPoint, title: nil, image: nil, completion: nil)
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.toastPoint, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    func changeMic(from: Int, to: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        let params: Dictionary<String, Int> = [
            "from": from,
            "to": to
        ]
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .exchangeMic(roomId: roomId), params: params) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("changeMic success!")
                    self.local_index = to
                } else {
                    self.view.makeToast("changeMic failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func showMuteView(with index: Int) {
        let isHairScreen = SwiftyFitsize.isFullScreen
        let muteView = VMMuteView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: isHairScreen ? 264~ : 264~ - 34))
        guard let mic_info = roomInfo?.mic_info?[index] else {return}
        muteView.isOwner = isOwner
        muteView.micInfo = mic_info
        muteView.resBlock = {[weak self] (state) in
            if state == .leave {
                self?.leaveMic(with: index)
            } else if state == .mute {
                self?.muteLocal(with: index)
            } else {
                self?.unmuteLocal(with: index)
            }
        }
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: isHairScreen ? 264~ : 264~ - 34)), custom: muteView)
        self.presentViewController(vc)
    }
    
    func leaveRoom() {
        guard let room_id = roomInfo?.room?.room_id else {return}
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: room_id), params: [:]) { map, err in
            print(map?["result"] as? Bool ?? false)
        }
    }
        
    func refuse() {
        if let roomId = self.roomInfo?.room?.room_id {
            VoiceRoomBusinessRequest.shared.sendGETRequest(api: .refuseInvite(roomId: roomId), params: [:]) { _, _ in
            }
        }
    }
    
    func agreeInvite() {
        if let roomId = self.roomInfo?.room?.room_id {
            VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .agreeInvite(roomId: roomId), params: [:]) { _, _ in
                
            }
        }
    }
    
    func showInviteMicAlert() {
        var compent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth-75, height: 200))
        compent.destination = .center
        let micAlert = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth-75, height: 200), content: "Anchor Invited You On-Stage",cancel: "Decline",confirm: "Accept",position: .center).cornerRadius(16).backgroundColor(.white)
        let vc = VoiceRoomAlertViewController(compent: compent, custom: micAlert)
        micAlert.actionEvents = { [weak self] in
            if $0 == 30 {
                self?.refuse()
            } else {
                self?.agreeInvite()
            }
            vc.dismiss(animated: true)
        }
        self.presentViewController(vc)
    }
}
//MARK: - SVGAPlayerDelegate
extension VoiceRoomViewController: SVGAPlayerDelegate {
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        let animation = self.view.viewWithTag(199)
        UIView.animate(withDuration: 0.3) {
            animation?.alpha = 0
        } completion: { finished in
            if finished { animation?.removeFromSuperview() }
        }
    }
}


//MARK: - ASManagerDelegate
extension VoiceRoomViewController: ASManagerDelegate {
    
    func didRtcLocalUserJoinedOfUid(uid: UInt) {
        
    }
    
    func didRtcRemoteUserJoinedOfUid(uid: UInt) {
        
    }
    
    func didRtcUserOfflineOfUid(uid: UInt) {
        
    }
    
    func reportAlien(with type: ALIEN_TYPE, musicType: VMMUSIC_TYPE) {
        print("当前是：\(type.rawValue)在讲话")
        self.rtcView.showAlienMicView = type
        if type == .ended && self.alienCanPlay && musicType == .alien {
            self.alienCanPlay = false
        }
    }
    
    func reportAudioVolumeIndicationOfSpeakers(speakers: [AgoraRtcAudioVolumeInfo]) {
        guard let micinfo = self.roomInfo?.mic_info else {return}
        for speaker in speakers {
            for (index,mic) in micinfo.enumerated() {
                guard let user = mic.member else {return}
                guard let rtcUid = Int(user.rtc_uid ?? "0") else {return}
                if rtcUid == speaker.uid {
                    var mic = micinfo[index]
                    mic.member?.volume = Int(speaker.volume)
                    self.roomInfo?.mic_info![index] = mic
                    self.rtcView.micInfos = self.roomInfo?.mic_info
                }
            }
        }
    }
}
