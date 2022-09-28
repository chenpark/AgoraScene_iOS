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

public enum ROLE_TYPE {
    case owner
    case audience
}

fileprivate let giftMap = [["gift_id":"VoiceRoomGift1","gift_name":LanguageManager.localValue(key: "Sweet Heart"),"gift_price":"1","gift_count":"1","selected":true],["gift_id":"VoiceRoomGift2","gift_name":LanguageManager.localValue(key: "Flower"),"gift_price":"2","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift3","gift_name":LanguageManager.localValue(key: "Crystal Box"),"gift_price":"10","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift4","gift_name":LanguageManager.localValue(key: "Super Agora"),"gift_price":"20","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift5","gift_name":LanguageManager.localValue(key: "Star"),"gift_price":"50","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift6","gift_name":LanguageManager.localValue(key: "Lollipop"),"gift_price":"100","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift7","gift_name":LanguageManager.localValue(key: "Diamond"),"gift_price":"500","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift8","gift_name":LanguageManager.localValue(key: "Crown"),"gift_price":"1000","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift9","gift_name":LanguageManager.localValue(key: "Rocket"),"gift_price":"1500","gift_count":"1","selected":false]]

class VoiceRoomViewController: VRBaseViewController {
    
    private var headerView: AgoraChatRoomHeaderView!
    private var rtcView: AgoraChatRoomNormalRtcView!
    private var sRtcView: AgoraChatRoom3DRtcView!
    
    @UserDefault("VoiceRoomUserAvatar", defaultValue: "") var userAvatar
    
    private lazy var giftList: VoiceRoomGiftView  = {
        VoiceRoomGiftView(frame: CGRect(x: 10, y: self.chatView.frame.minY - (ScreenWidth/9.0*2), width: ScreenWidth/3.0*2, height: ScreenWidth/9.0*1.8)).backgroundColor(.clear)
    }()
    
    private lazy var chatView: VoiceRoomChatView = {
        VoiceRoomChatView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - (ScreenHeight/667)*210 - 50, width: ScreenWidth, height:(ScreenHeight/667)*210))
    }()
    
    private lazy var chatBar: VoiceRoomChatBar = {
        VoiceRoomChatBar(frame: CGRect(x: 0, y: ScreenHeight-CGFloat(ZBottombarHeight)-50, width: ScreenWidth, height: 50),style:self.roomInfo?.room?.type ?? 0 == 1 ? .spatialAudio:.normal)
    }()
    
    private lazy var inputBar: VoiceRoomInputBar = {
        VoiceRoomInputBar(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 60)).backgroundColor(.white)
    }()
    
    private lazy var giftsAlert: VoiceRoomGiftsView = {
        VoiceRoomGiftsView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (110/84.0)*((ScreenWidth-30)/4.0)+180), gifts: self.gifts()).backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
    }()
    
    private var preView: VMPresentView!
    private var noticeView: VMNoticeView!
    private var isShowPreSentView: Bool = false
    private var rtckit: ASRTCKit = ASRTCKit.getSharedInstance()
    private var isOwner: Bool = false
    private var ains_state: AINS_STATE = .mid
    private var local_index: Int? = nil
    private var alienCanPlay: Bool = true
    
    public var roomInfo: VRRoomInfo? {
        didSet {
            if let entity = roomInfo?.room {
                if headerView == nil {return}
                headerView.entity = entity
            }
            
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
        isOwner = user.uid == owner.uid
        local_index = isOwner ? 0 : nil
        
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
        VoiceRoomIMManager.shared?.delegate = nil
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
    }
    
}

extension VoiceRoomViewController {
    //加载RTC
    private func loadKit() {
        
        guard let channel_id = self.roomInfo?.room?.channel_id else {return}
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        rtckit.setClientRole(role: isOwner ? .owner : .audience)
        rtckit.delegate = self
        
        var rtcJoinSuccess: Bool = false
        var IMJoinSuccess: Bool = false
        
        let VMGroup = DispatchGroup()
        let VMQueue = DispatchQueue(label: "com.agora.vm.www")
        
        VMGroup.enter()
        VMQueue.async {[weak self] in
            rtcJoinSuccess = self?.rtckit.joinVoicRoomWith(with: "\(channel_id)", rtcUid: 0, scene: .live) == 0
            VMGroup.leave()
        }
        
        VMGroup.enter()
        VMQueue.async {[weak self] in
            
            VoiceRoomIMManager.shared?.joinedChatRoom(roomId: roomId, completion: {[weak self] room, error in
                if error == nil {
                    IMJoinSuccess = true
                    VMGroup.leave()
                    self?.view.makeToast("join IM success!")
                } else {
                    self?.view.makeToast("\(error?.errorDescription ?? "")")
                    IMJoinSuccess = false
                    VMGroup.leave()
                    self?.view.makeToast("join IM failed!")
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
    
    //加入房间获取房间详情
    private func requestRoomDetail() {
        
        //如果不是房主。需要主动获取房间详情
        guard let room_id = self.roomInfo?.room?.room_id else {return}
        VoiceRoomBusinessRequest.shared.sendGETRequest(api: .fetchRoomInfo(roomId: room_id), params: [:], classType: VRRoomInfo.self) {[weak self] room, error in
            if error == nil {
                guard let info = room else { return }
                self?.roomInfo = info
            } else {
                self?.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func layoutUI() {
        
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
            self.view.addSubViews([self.chatView,self.giftList,self.chatBar,self.inputBar])
            self.inputBar.isHidden = true
        }
        
    }
    
    private func uploadStatus( status: Bool) {
        guard let roomId = self.roomInfo?.room?.room_id  else { return }
//        let pwd: String = roomInfo?.room?.roomPassword ?? ""
//        let params: Dictionary<String, Any> = ["password": pwd]
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .joinRoom(roomId: roomId), params: [:]) { dic, error in
            if let result = dic?["result"] as? Bool,error == nil,result {
                self.view.makeToast("Joined successful!")
            } else {
                self.didHeaderAction(with: .back)
            }
        }
    }
    
    @objc private func resignKeyboard() {
        self.inputBar.hiddenInputBar()
    }

    private func didHeaderAction(with action: HEADER_ACTION) {
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
    
    private func didRtcAction(with type: AgoraChatRoomBaseUserCellType, tag: Int) {
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
            if alienCanPlay {
                rtckit.playBaseAlienMusic()
            }
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
    
    private func notifySeverLeave() {
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
    
    private func showNoticeView(with role: ROLE_TYPE) {
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
    
    private func showSoundView() {
        
    }
    
    private func showActiveAlienView(_ active: Bool) {
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
    
    private func activeAlien(_ flag: Bool) {
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
    private func updateNotice(with str: String) {
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
    
    private func updateVolume(_ Vol: Int) {
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
                    }
                } else {
                    print("调节机器人音量失败")
                }
            } else {
                
            }
        }
    }
    
//    private func leaveRoom() {
//        guard let roomId = roomInfo?.room?.room_id else {return}
//        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: roomId), params: [:]) {[weak self] map, error in
//            if map != nil {
//                //如果返回的结果为true 表示上麦成功
//                if let result = map?["result"] as? Bool,error == nil,result {
//                    debugPrint("--- giveupStage :result:\(result)")
//                    self?.requestRoomDetail()
//                } else {
//                    self?.view.makeToast("leaveRoom failed!")
//                }
//            } else {
//
//            }
//        }
//    }
    
    private func getApplyList() {
        guard let roomId = roomInfo?.room?.room_id else {return}
        
    }
    
    private func showEQView() {
        preView = VMPresentView(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 450~))
        preView.isAudience = !isOwner
        preView.roomInfo = roomInfo
        preView.ains_state = ains_state
        preView.selBlock = {[weak self] state in
            self?.ains_state = state
            self?.rtckit.setAINS(with: state)
        }
        preView.useRobotBlock = {[weak self] flag in
            if self?.alienCanPlay == true && flag == true {
                self?.rtckit.playBaseAlienMusic()
            }
            
            if self?.alienCanPlay == true && flag == false {
                self?.rtckit.stopPlayBaseAlienMusic()
            }

            self?.activeAlien(flag)
        }
        preView.volBlock = {[weak self] vol in
            self?.updateVolume(vol)
        }
        self.view.addSubview(preView)
        self.isShowPreSentView = true
        self.sRtcView.isUserInteractionEnabled = false
        self.rtcView.isUserInteractionEnabled = false
        self.headerView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.preView.frame = CGRect(x: 0, y: ScreenHeight - 450~, width: ScreenWidth, height: 450~)
        }, completion: nil)
    }
    
    private func charBarEvents() {
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
    
    private func sendTextMessage(text: String) {
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        guard let userName = VoiceRoomUserInfo.shared.user?.name  else { return }
        VoiceRoomIMManager.shared?.sendMessage(roomId: roomId, text: text,ext: ["userName":userName]) { message, error in
            self.inputBar.endEditing(true)
            self.inputBar.inputField.text = ""
            if error == nil,message != nil {
                self.showMessage(message: message!)
            } else {
                self.view.makeToast("\(error?.errorDescription ?? "")")
            }
        }
    }
    
    private func changeHandsUpState() {
        if self.isOwner {
            self.applyMembersAlert()
        } else {
            if self.chatBar.handsState == .unSelected {
                self.userApplyAlert(nil)
            } else if self.chatBar.handsState == .selected {
                self.userCancelApplyAlert()
            }
        }
    }
    
    private func changeMicState() {
        self.chatBar.micState = !self.chatBar.micState
        self.chatBar.refresh(event: .mic, state: self.chatBar.micState ? .selected:.unSelected, asCreator: false)
        //需要根据麦位特殊处理
        self.chatBar.micState == false ? self.muteLocal(with: 0):self.unmuteLocal(with: 0)
    }
    
    private func showUsers() {
        let contributes = VoiceRoomUserView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 420),controllers: [VoiceRoomGiftersViewController(roomId: self.roomInfo?.room?.room_id ?? "")],titles: [LanguageManager.localValue(key: "Contribution List")]).cornerRadius(20, [.topLeft,.topRight], .white, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 420)), custom: contributes)
        self.presentViewController(vc)
    }
    
    private func showApplyAlert(_ index: Int) {
        let isHairScreen = SwiftyFitsize.isFullScreen
        let manageView = VMManagerView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height:isHairScreen ? 264~ : 264~ - 34))
        guard let mic_info = roomInfo?.mic_info?[index] else {return}
        manageView.micInfo = mic_info
        manageView.resBlock = {[weak self] (state, flag) in
            self?.dismiss(animated: true)
            if state == .invite {
                if flag {
                    self?.applyMembersAlert()
                } else {
                    self?.kickoff(with: index)
                }
            } else if state == .mute {
                if flag {
                    self?.mute(with: index)
                } else {
                    self?.unMute(with: index)
                }
            } else {
                if flag {
                    self?.lock(with: index)
                } else {
                    self?.unLock(with: index)
                }
            }
        }
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: isHairScreen ? 264~ : 264~ - 34)), custom: manageView)
        self.presentViewController(vc)
    }
    
    private func userApplyAlert(_ index: Int?) {
        let applyAlert = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (205/375.0)*ScreenWidth),content: "Request to Speak?",cancel: "Cancel",confirm: "Confirm").backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (205/375.0)*ScreenWidth)), custom: applyAlert)
        applyAlert.actionEvents = { [weak self] in
            if $0 == 31 {
                self?.requestSpeak(index: index)
            }
            vc.dismiss(animated: true)
        }
        self.presentViewController(vc)
    }
    
    private func requestSpeak(index: Int?) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .submitApply(roomId: roomId), params: index != nil ? ["mic_index":index ?? 2]:[:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.chatBar.refresh(event: .handsUp, state: .selected, asCreator: false)
                    self.view.makeToast("Apply success!")
                } else {
                    self.view.makeToast("Apply failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func cancelRequestSpeak(index: Int?) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .cancelApply(roomId: roomId), params: [:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("Cancel Apply success!")
                    self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: false)
                } else {
                    self.view.makeToast("Cancel Apply failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func userCancelApplyAlert() {
        let cancelAlert = VoiceRoomCancelAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (205/375.0)*ScreenWidth)).backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (205/375.0)*ScreenWidth)), custom: cancelAlert)
        cancelAlert.actionEvents = { [weak self] in
            if $0 == 30 {
                self?.cancelRequestSpeak(index: nil)
            }
            vc.dismiss(animated: true)
        }
        self.presentViewController(vc)
    }
    
    //禁言指定麦位
    private func mute(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .muteMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("mute success!")
                } else {
                    self.view.makeToast("mute failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //取消禁言指定麦位
    private func unMute(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .unmuteMic(roomId: roomId, index: index), params: [:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("unmute success!")
                    self.chatBar.refresh(event: .handsUp, state: .unSelected, asCreator: false)
                } else {
                    self.view.makeToast("unmute failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //踢用户下麦
    private func kickoff(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
        let dic: Dictionary<String, Any> = [
            "uid":mic.member?.uid ?? 0,
            "mic_index": index
        ]
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .kickMic(roomId: roomId), params: dic) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("kickoff success!")
                } else {
                    self.view.makeToast("kickoff failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //锁麦
    private func lock(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .lockMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("lock success!")
                } else {
                    self.view.makeToast("lock failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //取消锁麦
    private func unLock(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .unlockMic(roomId: roomId, index: index), params: [:]) { dic, error in
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("unLock success!")
                } else {
                    self.view.makeToast("unLock failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //下麦
    private func leaveMic(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveMic(roomId: roomId, index: index), params: [:]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("leaveMic success!")
//                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
//                    var mic_info = mic
//                    mic_info.status = -1
//                    self.roomInfo?.mic_info![index] = mic_info
//                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("leaveMic failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    //mute自己
    private func muteLocal(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .closeMic(roomId: roomId), params: ["mic_index": index]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("mute local success!")
//                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
//                    var mic_info = mic
//                    mic_info.status = 1
//                    self.roomInfo?.mic_info![index] = mic_info
//                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("unmute local failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }

    //unmute自己
    private func unmuteLocal(with index: Int) {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .cancelCloseMic(roomId: roomId, index: index), params: [:]) { dic, error in
            self.dismiss(animated: true)
            if error == nil,dic != nil,let result = dic?["result"] as? Bool {
                if result {
                    self.view.makeToast("unmuteLocal success!")
//                    guard let mic: VRRoomMic = self.roomInfo?.mic_info![index] else {return}
//                    var mic_info = mic
//                    mic_info.status = 0
//                    self.roomInfo?.mic_info![index] = mic_info
//                    self.rtcView.micInfos = self.roomInfo?.mic_info
                } else {
                    self.view.makeToast("unmuteLocal failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func changeMic(from: Int, to: Int) {
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
    
    private func showMuteView(with index: Int) {
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
    
    private func applyMembersAlert() {
        let userAlert = VoiceRoomUserView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 420),controllers: [VoiceRoomApplyUsersViewController(roomId: self.roomInfo?.room?.room_id ?? ""),VoiceRoomInviteUsersController(roomId: self.roomInfo?.room?.room_id ?? "")],titles: [LanguageManager.localValue(key: "Raised Hands"),LanguageManager.localValue(key: "Invite On-Stage")]).cornerRadius(20, [.topLeft,.topRight], .white, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 420)), custom: userAlert)
        self.presentViewController(vc)
    }
    
    private func showGiftAlert() {
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (110/84.0)*((ScreenWidth-30)/4.0)+180)), custom: self.giftsAlert)
        self.giftsAlert.sendClosure = { [weak self] in
            self?.sendGift(gift: $0)
            if $0.gift_id == "VoiceRoomGift9" {
                vc.dismiss(animated: true)
            }
        }
        self.presentViewController(vc)
    }
    
    private func sendGift(gift: VoiceRoomGiftEntity) {
        if let chatroom_id = self.roomInfo?.room?.chatroom_id,let uid = self.roomInfo?.room?.owner?.uid,let id = gift.gift_id,let name = gift.gift_name,let value = gift.gift_price,let count = gift.gift_count {
            VoiceRoomIMManager.shared?.sendCustomMessage(roomId: chatroom_id, event: VoiceRoomGift, customExt: ["gift_id":id,"gift_name":name,"gift_price":value,"gift_count":count,"userNaem":VoiceRoomUserInfo.shared.user?.name ?? "","portrait":VoiceRoomUserInfo.shared.user?.portrait ?? self.userAvatar], completion: { message, error in
                if error == nil,message != nil {
                    gift.userName = VoiceRoomUserInfo.shared.user?.name ?? ""
                    gift.portrait = VoiceRoomUserInfo.shared.user?.portrait ?? self.userAvatar
                    self.giftList.gifts.append(gift)
                    if let c = Int(count),let v = Int(value),var amount = VoiceRoomUserInfo.shared.user?.amount {
                        amount += c*v
                        VoiceRoomUserInfo.shared.user?.amount = amount
                    }
                    if id == "VoiceRoomGift9" {
                        self.rocketAnimation()
                    }
                    self.notifyServerGiftInfo(id: id, count: count, uid: uid)
                } else {
                    self.view.makeToast("Send failed \(error?.errorDescription ?? "")")
                }
            })
        }
    }
    
    private func notifyServerGiftInfo(id: String,count: String,uid: String) {
        if let roomId = self.roomInfo?.room?.room_id {
            VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .giftTo(roomId: roomId), params: ["gift_id":id,"num":Int(count) ?? 1,"to_uid":uid]) { dic, error in
                if let result = dic?["result"] as? Bool,error == nil,result {
                    self.view.makeToast("Send successful!")
                    debugPrint("result:\(result)")
                } else {
                    self.view.makeToast("Send failed!")
                }
            }
        }
    }
    
    func rocketAnimation() {
        let player = SVGAPlayer(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        player.loops = 1
        player.clearsAfterStop = true
        player.contentMode = .scaleAspectFill
        player.delegate = self
        player.tag(199)
        self.view.addSubview(player)
        let parser = SVGAParser()
        parser.parse(withNamed: "rocket", in: .main) { entitiy in
            player.videoItem = entitiy
            player.startAnimation()
        } failureBlock: { error in
            player.removeFromSuperview()
        }
    }
    
    private func gifts() -> [VoiceRoomGiftEntity] {
        var gifts = [VoiceRoomGiftEntity]()
        for dic in giftMap {
            gifts.append(model(from: dic, VoiceRoomGiftEntity.self))
        }
        return gifts
    }
    
    func reLogin() {
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":VoiceRoomUserInfo.shared.user?.portrait ?? self.userAvatar,"name":VoiceRoomUserInfo.shared.user?.name ?? ""],classType:VRUser.self) { [weak self] user, error in
            if error == nil {
                VoiceRoomUserInfo.shared.user = user
                VoiceRoomBusinessRequest.shared.userToken = user?.authorization ?? ""
                AgoraChatClient.shared().renewToken(user?.im_token ?? "")
            } else {
                self?.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func leaveRoom() {
        guard let room_id = roomInfo?.room?.room_id else {return}
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: room_id), params: [:]) { map, err in
            print(map?["result"] as? Bool ?? false)
        }
    }
    
    private func showMessage(message: AgoraChatMessage) {
        if let body = message.body as? AgoraChatTextMessageBody,let userName = message.ext?["userName"] as? String {
            self.convertShowText(userName: userName, content: body.text,joined: false)
        }
    }
    
    private func convertShowText(userName: String,content: String,joined: Bool) {
        let dic = ["userName":userName,"content":content]
        self.chatView.messages?.append(self.chatView.getItem(dic: dic, join: joined))
        DispatchQueue.main.async {
            self.perform(#selector(VoiceRoomViewController.refreshChatView), with: nil, afterDelay: 1)
        }
    }
    
    @objc func refreshChatView() {
        self.chatView.chatView.reloadData()
        let row = (self.chatView.messages?.count ?? 0) - 1
        self.chatView.chatView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: true)
    }
    
    private func refuse() {
        if let roomId = self.roomInfo?.room?.room_id {
            VoiceRoomBusinessRequest.shared.sendGETRequest(api: .refuseInvite(roomId: roomId), params: [:]) { _, _ in
            }
        }
    }
    
    private func agreeInvite() {
        if let roomId = self.roomInfo?.room?.room_id {
            VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .agreeInvite(roomId: roomId), params: [:]) { _, _ in
                
            }
        }
    }
    
    private func showInviteMicAlert() {
        var compent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth-75, height: 200))
        compent.destination = .center
        let micAlert = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth-75, height: 200), content: "Anchor Invited You On-Stage",cancel: "Decline",confirm: "Accept").cornerRadius(16).backgroundColor(.white)
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

//MARK: - VoiceRoomIMDelegate
extension VoiceRoomViewController: VoiceRoomIMDelegate {
    
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
        self.giftList.gifts.append(model(from: dic, VoiceRoomGiftEntity.self))
        if let id = meta?["gift_id"],id == "VoiceRoomGift9" {
            self.rocketAnimation()
        }
    }
    
    func receiveApplySite(roomId: String, meta: [String : String]?) {
        let user = model(from: meta ?? [:], VRUser.self)
        if VoiceRoomUserInfo.shared.user?.uid  ?? "" != user.uid ?? "" {
            return
        }
        self.chatBar.refresh(event: .handsUp, state: .selected, asCreator: self.isOwner)
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
        self.view.makeToast("User \(user.name ?? "") refuse invite")
    }
    
    func userJoinedRoom(roomId: String, username: String) {
        self.convertShowText(userName: username, content: LanguageManager.localValue(key: "Joined"),joined: true)
    }
    
    func announcementChanged(roomId: String, content: String) {
        self.view.makeToast("Voice room announcement changed!")
        guard let _ = roomInfo?.room else {return}
        roomInfo?.room!.announcement = content
    }
    
    func userBeKicked(roomId: String, reason: AgoraChatroomBeKickedReason) {
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
        VoiceRoomIMManager.shared?.delegate = nil
        var message = ""
        switch reason {
        case .beRemoved: message = "you be removed by owner"
        case .destroyed: message = "VoiceRoom is destroyed"
        case .offline: message = "you are offline"
        @unknown default:
            break
        }
        self.view.makeToast(message)
        if reason == .destroyed {
            self.backAction()
        }
    }
    
    func roomAttributesDidUpdated(roomId: String, attributeMap: [String : String]?, from fromId: String) {
        self.view.makeToast("roomId:\(roomId),attributeMap:\(attributeMap)")
        guard let dic = getMicStatus(with: attributeMap) else {return}
        var index: Int = dic["index"] ?? 0
        let status: Int = dic["status"] ?? 0
        if index > 6 {index = 6}
        guard let mic: VRRoomMic = roomInfo?.mic_info![index] else {return}
        var mic_info = mic
        mic_info.status = status
        if status == 5 || status == -2 {
            self.roomInfo?.room?.use_robot = status == 5
        }
        self.roomInfo?.mic_info![index] = mic_info
        self.rtcView.micInfos = self.roomInfo?.mic_info
        requestRoomDetail()
    }
    
    func roomAttributesDidRemoved(roomId: String, attributes: [String]?, from fromId: String) {
        
    }
    
    private func getMicStatus(with map: [String : String]?) -> Dictionary<String, Int>? {
        guard let mic_info = map else {return nil}
        var first: Dictionary<String, Int>? = Dictionary()
        for mic in mic_info {
            let key: String = mic.key
            let value = getDictionaryFromJSONString(jsonString: mic.value)
            
            first!.updateValue(value["status"] as! Int, forKey: "status")
            if key.contains("mic_") {
                if key.components(separatedBy: "mic_").count > 1 {
                    let mic_index = key.components(separatedBy: "mic_")[1]
                    first!.updateValue(Int(mic_index)!, forKey: "index")
                    
                    let uid = VoiceRoomUserInfo.shared.user?.uid
                    if value.keys.contains("uid") {
                        if uid == value["uid"] as? String ?? "" {
                            local_index = Int(mic_index)
                        }
                    }
                    
                    return first
                }
            }
        }
        return nil
    }
    
   private func getDictionaryFromJSONString(jsonString:String) ->Dictionary<String, Any>{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! Dictionary
        }
        return Dictionary()
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
    
    func reportAlien(with type: ALIEN_TYPE) {
        print("当前是：\(type.rawValue)在讲话")
        self.rtcView.showAlienMicView = type
        if type == .ended && self.alienCanPlay {
            self.alienCanPlay = false
        }
    }
}
