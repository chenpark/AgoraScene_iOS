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

public enum ROLE_TYPE {
    case owner
    case audience
}

fileprivate let giftMap = [["gift_id":"VoiceRoomGift1","gift_name":LanguageManager.localValue(key: "Sweet Heart"),"gift_value":"1","gift_count":"1","selected":true],["gift_id":"VoiceRoomGift2","gift_name":LanguageManager.localValue(key: "Flower"),"gift_value":"2","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift3","gift_name":LanguageManager.localValue(key: "Crystal Box"),"gift_value":"10","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift4","gift_name":LanguageManager.localValue(key: "Super Agora"),"gift_value":"20","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift5","gift_name":LanguageManager.localValue(key: "Star"),"gift_value":"50","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift6","gift_name":LanguageManager.localValue(key: "Lollipop"),"gift_value":"100","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift7","gift_name":LanguageManager.localValue(key: "Diamond"),"gift_value":"500","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift8","gift_name":LanguageManager.localValue(key: "Crown"),"gift_value":"1000","gift_count":"1","selected":false],["gift_id":"VoiceRoomGift9","gift_name":LanguageManager.localValue(key: "Rocket"),"gift_value":"1500","gift_count":"1","selected":false]]

class VoiceRoomViewController: VRBaseViewController, SVGAPlayerDelegate {
    
    private var headerView: AgoraChatRoomHeaderView!
    private var rtcView: AgoraChatRoomNormalRtcView!
    private var sRtcView: AgoraChatRoom3DRtcView!
    
    lazy var giftList: VoiceRoomGiftView  = {
        VoiceRoomGiftView(frame: CGRect(x: 10, y: self.chatView.frame.minY - (ScreenWidth/9.0*2), width: ScreenWidth/3.0*2, height: ScreenWidth/9.0*1.8)).backgroundColor(.clear)
    }()
    
    private lazy var chatView: VoiceRoomChatView = {
        VoiceRoomChatView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - (ScreenHeight/667)*210 - 50, width: ScreenWidth, height:(ScreenHeight/667)*210))
    }()
    
    private lazy var chatBar: VoiceRoomChatBar = {
        VoiceRoomChatBar(frame: CGRect(x: 0, y: ScreenHeight-CGFloat(ZBottombarHeight)-50, width: ScreenWidth, height: 50),style:.normal)
    }()
    
    private lazy var inputBar: VoiceRoomInputBar = {
        VoiceRoomInputBar(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 60)).backgroundColor(.white)
    }()
    
    private var preView: VMPresentView!
    private var noticeView: VMNoticeView!
    private var isShowPreSentView: Bool = false
    private var rtckit: ASRTCKit = ASRTCKit.getSharedInstance()
    private var isOwner: Bool = false
    
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
            
            guard let user = VoiceRoomUserInfo.shared.user else {return}
            guard let owner = self.roomInfo?.room?.owner else {return}
            isOwner = user.uid == owner.uid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRoomIMManager.shared?.delegate = self
        
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
            rtcJoinSuccess = self?.rtckit.joinVoicRoomWith(with: channel_id, rtcUid: 0, scene: .live) == 0
            VMGroup.leave()
        }
        
        VMGroup.enter()
        VMQueue.async {[weak self] in
            
            VoiceRoomIMManager.shared?.joinedChatRoom(roomId: roomId, completion: {[weak self] room, error in
                if error == nil {
                    IMJoinSuccess = true
                    VMGroup.leave()
                } else {
                    self?.view.makeToast("\(error?.errorDescription ?? "")")
                    IMJoinSuccess = false
                    VMGroup.leave()
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
        if !isOwner {
            VoiceRoomBusinessRequest.shared.sendGETRequest(api: .fetchRoomInfo(roomId: room_id), params: [:], classType: VRRoomInfo.self) {[weak self] room, error in
                if error == nil {
                    guard let info = room else { return }
                    self?.roomInfo = info
                } else {
                    self?.view.makeToast("\(error?.localizedDescription ?? "")")
                }
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
        self.view.addSubViews([self.chatView,self.giftList,self.chatBar,self.inputBar])
        self.inputBar.isHidden = true
        
    }
    
    private func uploadStatus( status: Bool) {
        guard let roomId = self.roomInfo?.room?.room_id  else { return }
        let pwd: String = roomInfo?.room?.roomPassword ?? ""
        let params: Dictionary<String, Any> = ["password": pwd]
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .joinRoom(roomId: roomId), params: params) { dic, error in
            if let result = dic?["result"] as? Bool,error == nil,result {
                self.view.makeToast("Joined successful!")
            } else {
                self.didHeaderAction(with: .back)
            }
        }
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
            showNoticeView(with: .owner)
        } else if action == .rank {
            //展示土豪榜
            self.showUsers()
        } else if action == .soundClick {
            showSoundView()
        }
    }
    
    private func didRtcAction(with type: AgoraChatRoomBaseUserCellType, tag: Int) {
        if type == .AgoraChatRoomBaseUserCellTypeAdd {
            userApplyAlert(tag - 200)
        } else if type == .AgoraChatRoomBaseUserCellTypeAlienActive {
            showActiveAlienView(true)
        } else if type == .AgoraChatRoomBaseUserCellTypeAlienNonActive {
            showActiveAlienView(false)
        }
    }
    
    private func notifySeverLeave() {
        guard let roomId = self.roomInfo?.room?.chatroom_id  else { return }
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: roomId), params: [:]) { dic, error in
            if let result = dic?["result"] as? Bool,error == nil,result {
                debugPrint("result:\(result)")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.inputBar.endEditing(true)
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
        noticeView.resBlock = {[weak self] (flag, str) in
            self?.dismiss(animated: true)
            guard let str = str else {return}
            //修改群公告
            
        }
        let noticeStr = self.roomInfo?.room?.announcement ?? ""
        noticeView.noticeStr = noticeStr
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 220~)), custom: noticeView)
        self.presentViewController(vc)
    }
    
    private func showSoundView() {
        
    }
    
    private func showActiveAlienView(_ active: Bool) {
        let confirmView = VMConfirmView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 40~, height: 220~))
        var compent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth - 40~, height: 220~))
        compent.destination = .center
        let vc = VoiceRoomAlertViewController(compent: compent, custom: confirmView)
        confirmView.resBlock = {[weak self] (flag) in
            self?.dismiss(animated: true)
            //修改群公告
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
                        mic_info.status = 5
                        self.roomInfo?.mic_info![6] = mic_info
                    }
                } else {
                    print("激活机器人失败")
                }
            } else {
                
            }
        }
    }
    
//    private func showUpStage(with tag: Int) {
//        let stageView = VMUpstageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 220~))
//        stageView.resBlock = {[weak self] flag in
//            self?.dismiss(animated: true)
//            if flag {
//                guard let roomId = self?.roomInfo?.room?.room_id else {return}
//                let index = tag - 200
//                guard let mic: VRRoomMic = self?.roomInfo?.mic_info![index] else {return}
//                let params: Dictionary<String, Any> = ["mic_index": index]
//                VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .submitApply(roomId: roomId), params: params) { map, error in
//                    if map != nil {
//                        //如果返回的结果为true 表示上麦成功
//                        if let result = map?["result"] as? Bool,error == nil,result {
//                            debugPrint("--- showUpStage :result:\(result)")
//                            var mic_info = mic
//                            mic_info.status = 0
//                            self?.roomInfo?.mic_info![index] = mic_info
//                            self?.rtcView.micInfos = self?.roomInfo?.mic_info
//                        } else {
//                            self?.view.makeToast("Apply failed!")
//                        }
//                    } else {
//
//                    }
//                }
//            }
//        }
//        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 220~)), custom: stageView)
//        self.presentViewController(vc)
//    }
    
    private func giveupStage() {
        guard let roomId = roomInfo?.room?.room_id else {return}
        VoiceRoomBusinessRequest.shared.sendDELETERequest(api: .leaveRoom(roomId: roomId), params: [:]) {[weak self] map, error in
            if map != nil {
                //如果返回的结果为true 表示上麦成功
                if let result = map?["result"] as? Bool,error == nil,result {
                    debugPrint("--- giveupStage :result:\(result)")
                    self?.requestRoomDetail()
                } else {
                    self?.view.makeToast("leaveRoom failed!")
                }
            } else {

            }
        }
    }
    
    private func getApplyList() {
        guard let roomId = roomInfo?.room?.room_id else {return}
        
    }
    
    private func showEQView(with role: ROLE_TYPE) {
        preView = VMPresentView(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: 450~))
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
            guard let `self` = self else { return }
            guard let roomId = self.roomInfo?.room?.room_id  else { return }
            guard let userName = VoiceRoomUserInfo.shared.user?.name  else { return }
            VoiceRoomIMManager.shared?.sendMessage(roomId: roomId, text: $0,ext: ["userName":userName]) { message, error in
                self.inputBar.endEditing(true)
                if error == nil,message != nil {
                    self.showMessage(message: message!)
                } else {
                    self.view.makeToast("\(error?.errorDescription ?? "")")
                }
            }
        }
        self.chatBar.events = { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .mic:
                self.chatBar.micState = !self.chatBar.micState
                self.chatBar.refresh(event: .mic, state: self.chatBar.micState ? .selected:.unSelected, asCreator: false)
            case .handsUp:
                if self.isOwner {
                    if self.chatBar.handsState == .selected {
                        self.chatBar.refresh(event: .mic, state: .unSelected, asCreator: true)
                    }
                    self.applyMembersAlert()
                } else {
                    if self.chatBar.handsState == .unSelected {
                        self.userApplyAlert(nil)
                    } else if self.chatBar.handsState == .disable {
                        self.userCancelApplyAlert()
                    }
                }
            case .gift:
                self.showGiftAlert()
            case .eq:
                self.showEQView(with: .audience)
            default: break
            }
        }
    }
    
    private func showUsers() {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        let tmp = VoiceRoomUserView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 420),controllers: [VoiceRoomGiftersViewController(roomId: roomId)],titles: [LanguageManager.localValue(key: "Contribution List")]).cornerRadius(20, [.topLeft,.topRight], .white, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 420)), custom: tmp)
        self.presentViewController(vc)
    }
    
    private func userApplyAlert(_ index: Int?) {
        let apply = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (205/375.0)*ScreenWidth),content: "Request to Speak?",cancel: "Cancel",confirm: "Confirm").backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (205/375.0)*ScreenWidth)), custom: apply)
        apply.actionEvents = { [weak self] in
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
                    self.view.makeToast("Apply success!")
                } else {
                    self.view.makeToast("Apply failed!")
                }
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func userCancelApplyAlert() {
        let apply = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (205/375.0)*ScreenWidth),content: "",cancel: "Cancel Request",confirm: "").backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (110/84.0)*((ScreenWidth-30)/4.0)+180)), custom: apply)
        apply.actionEvents = { [weak self] in
            if $0 == 30 {
                self?.cancelRequestSpeak(index: nil)
            }
            vc.dismiss(animated: true)
        }
        self.presentViewController(vc)
    }
    
    private func applyMembersAlert() {
        guard let roomId = self.roomInfo?.room?.room_id else { return }
        let userView = VoiceRoomUserView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 420),controllers: [VoiceRoomApplyUsersViewController(roomId: roomId),VoiceRoomInviteUsersController(roomId: roomId)],titles: [LanguageManager.localValue(key: "Raised Hands"),LanguageManager.localValue(key: "Invite On-Stage")]).cornerRadius(20, [.topLeft,.topRight], .white, 0)
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 420)), custom: userView)
        self.presentViewController(vc)
    }
    
    private func showGiftAlert() {
        let gift = VoiceRoomGiftsView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: (110/84.0)*((ScreenWidth-30)/4.0)+180), gifts: self.gifts()).backgroundColor(.white).cornerRadius(20, [.topLeft,.topRight], .clear, 0)
        gift.sendClosure = { [weak self] in
            self?.sendGift(gift: $0)
        }
        let vc = VoiceRoomAlertViewController(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: (110/84.0)*((ScreenWidth-30)/4.0)+180)), custom: gift)
        self.presentViewController(vc)
    }
    
    private func sendGift(gift: VoiceRoomGiftEntity) {
        if let chatroom_id = self.roomInfo?.room?.chatroom_id,let uid = self.roomInfo?.room?.owner?.uid,let id = gift.gift_id,let name = gift.gift_name,let value = gift.gift_value,let count = gift.gift_count {
            VoiceRoomIMManager.shared?.sendCustomMessage(roomId: chatroom_id, event: VoiceRoomGift, customExt: ["gift_id":id,"gift_name":name,"gift_value":value,"gift_count":count,"userNaem":VoiceRoomUserInfo.shared.user?.name ?? "","portrait":VoiceRoomUserInfo.shared.user?.portrait ?? ""], completion: { message, error in
                if error == nil,message != nil {
                    gift.userName = VoiceRoomUserInfo.shared.user?.name ?? ""
                    gift.portrait = VoiceRoomUserInfo.shared.user?.portrait ?? ""
                    self.giftList.gifts.append(gift)
                    if let c = Int(count),let v = Int(value),var amount = VoiceRoomUserInfo.shared.user?.amount {
                        amount += c*v
                        VoiceRoomUserInfo.shared.user?.amount = amount
                    }
                    if id == "VoiceRoomGift9" {
                        self.rocketAnimation()
                    }
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
                } else {
                    self.view.makeToast("Send failed \(error?.errorDescription ?? "")")
                }
            })
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
    
    func svgaPlayerDidFinishedAnimation(_ player: SVGAPlayer!) {
        let animation = self.view.viewWithTag(199)
        UIView.animate(withDuration: 0.3) {
            animation?.alpha = 0
        } completion: { finished in
            if finished { animation?.removeFromSuperview() }
        }
    }
    
    private func gifts() -> [VoiceRoomGiftEntity] {
        var gifts = [VoiceRoomGiftEntity]()
        for dic in giftMap {
            var data = Data()
            do {
                data = try JSONSerialization.data(withJSONObject: dic, options: [])
                let entity = try JSONDecoder().decode(VoiceRoomGiftEntity.self, from: data)
                gifts.append(entity)
            } catch {
                assert(false, "\(error.localizedDescription)")
            }
        }
        return gifts
    }
    
    func reLogin() {
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":VoiceRoomUserInfo.shared.user?.portrait ?? "","name":VoiceRoomUserInfo.shared.user?.name ?? ""],classType:VRUser.self) { [weak self] user, error in
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
            VoiceRoomBusinessRequest.shared.sendGETRequest(api: .agreeInvite(roomId: roomId), params: [:]) { _, _ in
            }
        }
    }
}
//MARK: - VoiceRoomIMDelegate
extension VoiceRoomViewController: VoiceRoomIMDelegate {
    
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
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: [])
            let entity = try JSONDecoder().decode(VoiceRoomGiftEntity.self, from: data)
            self.giftList.gifts.append(entity)
        } catch {
            assert(false, "\(error.localizedDescription)")
        }
        if let id = meta?["gift_id"],id == "VoiceRoomGift9" {
            self.rocketAnimation()
        }
    }
    /// 只有owner会收到此回调
    func receiveApplySite(roomId: String, meta: [String : String]?) {
        self.chatBar.refresh(event: .handsUp, state: .selected, asCreator: true)
    }
    /// 只有观众会收到此回调
    func receiveInviteSite(roomId: String, meta: [String : String]?) {
        let alert = VoiceRoomApplyAlert(frame: CGRect(x: 0, y: 0, width: ScreenWidth-75, height: 65), content: "Anchor Invited You On-Stage",cancel: "Decline",confirm: "Accept").cornerRadius(16)
        var compent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth-75, height: 65))
        compent.destination = .center
        let vc = VoiceRoomAlertViewController(compent: compent, custom: alert)
        alert.actionEvents = { [weak self] in
            if $0 == 30 {
                self?.refuse()
            } else {
                self?.agreeInvite()
            }
            vc.dismiss(animated: true)
        }
        self.presentViewController(vc)
    }
    /// 只有owner会收到此回调
    func refuseInvite(roomId: String, meta: [String : String]?) {
        //        self.view.makeToast("")
    }
    
    func userJoinedRoom(roomId: String, username: String) {
        self.convertShowText(userName: username, content: LanguageManager.localValue(key: "Joined"),joined: true)
    }
    
    func announcementChanged(roomId: String, content: String) {
        self.view.makeToast("Voice room announcement changed!")
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
        
    }
    
    func roomAttributesDidRemoved(roomId: String, attributes: [String]?, from fromId: String) {
        
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
}
