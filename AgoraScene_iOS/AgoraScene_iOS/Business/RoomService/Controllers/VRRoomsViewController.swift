//
//  VRRoomsViewController.swift
//  Pods-VoiceRoomBaseUIKit_Example
//
//  Created by 朱继超 on 2022/8/24.
//

import UIKit
import ZSwiftBaseLib
import ProgressHUD

let bottomSafeHeight = safeAreaExist ? 33:0
let page_size = 15

public final class VRRoomsViewController: VRBaseViewController {
        
    @UserDefault("VoiceRoomUserAvatar", defaultValue: "") var userAvatar
    
    var index: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.container.index = self.index
            }
        }
    }
    
    private let all = VRAllRoomsViewController()
    private let normal = VRNormalRoomsViewController()
    private let spatialSound = VRSpatialSoundViewController()
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var menuBar: VRRoomMenuBar = {
        VRRoomMenuBar(frame: CGRect(x: 20, y: ZNavgationHeight, width: ScreenWidth-40, height: 35), items: VRRoomMenuBar.entities, indicatorImage: UIImage("fline")!,indicatorFrame: CGRect(x: 0, y: 35 - 2, width: 18, height: 2)).backgroundColor(.clear)
    }()
    
    lazy var container: VoiceRoomPageContainer = {
        VoiceRoomPageContainer(frame: CGRect(x: 0, y: self.menuBar.frame.maxY, width: ScreenWidth, height: ScreenHeight - self.menuBar.frame.maxY - 10 - CGFloat(ZBottombarHeight) - 30), viewControllers: [self.all,self.normal,self.spatialSound]).backgroundColor(.clear)
    }()
    
    lazy var create: VRRoomCreateView = {
        VRRoomCreateView(frame: CGRect(x: 0, y: self.container.frame.maxY - 50, width: ScreenWidth, height: 72)).image(UIImage("blur")!).backgroundColor(.clear)
    }()
    
    let avatar = UIButton {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth - 70, y: ZNavgationHeight - 40, width: 50, height: 30)).backgroundColor(.clear).tag(111)
        UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).contentMode(.scaleAspectFit).tag(112)
        UIImageView(frame: CGRect(x: 38, y: 9, width: 12, height: 12)).image(UIImage("arrow_right")!).contentMode(.scaleAspectFit)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.menuBar,self.container,self.create])
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = LanguageManager.localValue(key: "Agora Chat Room")
        self.navigation.addSubview(self.avatar)
        self.avatar.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        self.refreshAvatar()
        self.viewsAction()
        self.childViewControllersEvent()
        
    }
    

}

extension VRRoomsViewController {
        
    public override var backImageName: String { "" }
    
    public override func backAction() {
        
    }
    
    @objc func editProfile() {
        let vc = VRUserProfileViewController()
        vc.avatarChange = { [weak self] in
            self?.refreshAvatar()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshAvatar() {
        if let header = self.avatar.viewWithTag(112) as? UIImageView {
            header.image = UIImage(named: VoiceRoomUserInfo.shared.user?.portrait ?? self.userAvatar)
        }
    }
    
    private func viewsAction() {
        self.create.action = { [weak self] in
            self?.navigationController?.pushViewController(VRCreateRoomViewController.init(), animated: true)
        }
        self.container.scrollClosure = { [weak self] in
            let idx = IndexPath(row: $0, section: 0)
            guard let `self` = self else { return }
            self.menuBar.refreshSelected(indexPath: idx)
        }
        self.menuBar.selectClosure = { [weak self] in
            self?.index = $0.row
        }
    }
    
    private func entryRoom(room: VRRoomEntity) {
        if room.is_private ?? false {
            let alert = VoiceRoomPasswordAlert(frame: CGRect(x: 37.5, y: 168, width: ScreenWidth-75, height: (ScreenWidth-63-3*16)/4.0+177)).cornerRadius(16).backgroundColor(.white)
            let vc = VoiceRoomAlertViewController(compent: self.component(), custom: alert)
            self.presentViewController(vc)
            alert.actionEvents = {
                if $0 == 31 {
                    room.roomPassword = alert.code
                    self.validatePassword(room: room, password: alert.code)
                }
                vc.dismiss(animated: true)
            }
        } else {
            self.loginIMThenPush(room: room)
        }
        
    }
    
    private func component() -> PresentedViewComponent {
        var component = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: ScreenHeight))
        component.destination = .center
        component.canPanDismiss = false
        return component
    }
    
    private func validatePassword(room: VRRoomEntity,password: String) {
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .validatePassWord(roomId: room.room_id ?? ""), params: ["password":password]) { dic, error in
            if error == nil,let result = dic?["result"] as? Bool,result {
                self.loginIMThenPush(room: room)
            } else {
                self.view.makeToast("Password wrong!")
            }
        }
    }
    
    private func loginIMThenPush(room: VRRoomEntity) {
        ProgressHUD.show(NSLocalizedString("Loading", comment: ""),interaction: false)
        VoiceRoomIMManager.shared?.loginIM(userName: VoiceRoomUserInfo.shared.user?.chat_uid ?? "", token: VoiceRoomUserInfo.shared.user?.im_token ?? "", completion: { userName, error in
            ProgressHUD.dismiss()
            if error == nil {
                let info = VRRoomInfo()
                info.room = room
                let vc = VoiceRoomViewController(info: info)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.view.makeToast("Loading failed,please retry or install again!")
            }
        })
    }

    private func childViewControllersEvent() {
        self.all.didSelected = { [weak self] in
            self?.entryRoom(room: $0)
        }
        self.all.totalCountClosure = { [weak self] in
            guard let `self` = self else { return }
            self.menuBar.dataSource[0].detail = "(\($0))"
            self.menuBar.menuList.reloadData()
        }
        
        self.normal.didSelected = { [weak self] in
            self?.entryRoom(room: $0)
        }
        self.normal.totalCountClosure = { [weak self] in
            guard let `self` = self else { return }
            self.menuBar.dataSource[1].detail = "(\($0))"
            self.menuBar.menuList.reloadData()
        }
        
        self.spatialSound.didSelected = { [weak self] in
            self?.entryRoom(room: $0)
        }
        self.spatialSound.totalCountClosure = { [weak self] in
            guard let `self` = self else { return }
            self.menuBar.dataSource[2].detail = "(\($0))"
            self.menuBar.menuList.reloadData()
        }
    }
}
