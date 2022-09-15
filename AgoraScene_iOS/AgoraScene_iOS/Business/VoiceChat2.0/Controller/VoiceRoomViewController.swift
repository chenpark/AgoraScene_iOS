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

public enum ROLE_TYPE {
    case owner
    case audience
}

class VoiceRoomViewController: VRBaseViewController,VoiceRoomIMDelegate {
    
    private var headerView: AgoraChatRoomHeaderView!
    private var rtcView: AgoraChatRoomNormalRtcView!
    private var sRtcView: AgoraChatRoom3DRtcView!
    
    lazy var giftList: VoiceRoomGiftView  = {
        VoiceRoomGiftView(frame: CGRect(x: 10, y: self.chatView.frame.minY - (ScreenWidth/9.0*2), width: ScreenWidth/3.0*2, height: ScreenWidth/9.0*1.8)).backgroundColor(.clear)
    }()
    
    private lazy var chatView: VoiceRoomChatView = {
        VoiceRoomChatView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - (ScreenHeight/667)*210 - 50, width: ScreenWidth, height:(ScreenHeight/667)*210))
    }()
    
    lazy var chatBar: VoiceRoomChatBar = {
        VoiceRoomChatBar(frame: CGRect(x: 0, y: ScreenHeight-CGFloat(ZBottombarHeight)-50, width: ScreenWidth, height: 50),style:.normal)
    }()
    
    private var preView: VMPresentView!
    private var noticeView: VMNoticeView!
    private var isShowPreSentView: Bool = false
    
    public var roomInfo: VRRoomInfo? {
        didSet {
            
            if let entity = roomInfo?.room {
                if headerView == nil {return}
                headerView.entity = entity
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRoomIMManager.shared?.delegate = self
        requestRoomDetail()
        layoutUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigation.isHidden = false
    }
    
    deinit {
        VoiceRoomIMManager.shared?.delegate = nil
        VoiceRoomIMManager.shared?.userQuitRoom(completion: nil)
    }
    
}

extension VoiceRoomViewController {
    
    //加载RTC
    private func loadRtc() {
        
    }
    
    //加载IM
    private func loadIM() {
        guard let roomId = self.roomInfo?.room?.chat_room_id  else { return }
        VoiceRoomIMManager.shared?.joinedChatRoom(roomId: roomId, completion: { room, error in
            if error == nil {
                
            } else {
                self.view.makeToast("\(error?.errorDescription ?? "")")
            }
        })
    }
    
    //加入房间获取房间详情
    private func requestRoomDetail() {
        guard let user = VoiceRoomUserInfo.shared.user else {return}
        guard let owner = self.roomInfo?.room?.owner else {return}
        //如果不是房主。需要主动获取房间详情
        guard let room_id = self.roomInfo?.room?.room_id else {return}
        if user.uid != owner.uid {
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
        
            
        self.view.addSubViews([self.chatView,self.giftList,self.chatBar])
        headerView = AgoraChatRoomHeaderView()
        headerView.completeBlock = {[weak self] action in
            self?.didHeaderAction(with: action)
        }
        self.view.addSubview(headerView)
        
        self.sRtcView = AgoraChatRoom3DRtcView()
        self.view.addSubview(self.sRtcView)
        
        self.rtcView = AgoraChatRoomNormalRtcView()
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
        

//        self.chatView.snp.makeConstraints { make in
//            make.top.equalTo(self.rtcView.snp.bottom).offset(80);
//            make.left.right.equalTo(self.view);
//            make.height.equalTo(210~);
//        }
        
    }
    
    private func didHeaderAction(with action: HEADER_ACTION) {
        if action == .back {
            navigationController?.popViewController(animated: true)
        } else {
            showNoticeView(with: .owner)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

        }
        noticeView.noticeStr = "Welcome to Agora Chat Room 2.0 I am therobot Agora Red. Can you see the robot assistant at the right coner? Click it and experience the new features"
        let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 220~)), custom: noticeView)
        self.presentViewController(vc)
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
    
    //MARK: - VoiceRoomIMDelegate
    func chatTokenDidExpire(code: AgoraChatErrorCode) {
        
    }
    
    func chatTokenWillExpire(code: AgoraChatErrorCode) {
        
    }
    
    func receiveTextMessage(roomId: String, message: AgoraChatMessage) {
        if let body = message.body as? AgoraChatTextMessageBody {
            let dic = ["userName":message.from,"content":body.text]
            self.chatView.messages?.append(self.chatView.getItem(dic: dic, join: false))
        }
    }
    
    func receiveGift(roomId: String, meta: [String : String]?) {
        
    }
    
    func receiveApplySite(roomId: String, meta: [String : String]?) {
        
    }
    
    func receiveInviteSite(roomId: String, meta: [String : String]?) {
        
    }
    
    func refuseInvite(roomId: String, meta: [String : String]?) {
        
    }
    
    func userJoinedRoom(roomId: String, username: String) {
        
    }
    
    func announcementChanged(roomId: String, content: String) {
        
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
    }
    
    func roomAttributesDidUpdated(roomId: String, attributeMap: [String : String]?, from fromId: String) {
        
    }
    
    func roomAttributesDidRemoved(roomId: String, attributes: [String]?, from fromId: String) {
        
    }
    
}


