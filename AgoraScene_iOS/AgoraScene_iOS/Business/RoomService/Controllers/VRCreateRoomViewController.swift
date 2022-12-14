//
//  VRCreateRoomViewController.swift
//  Pods-VoiceRoomBaseUIKit_Example
//
//  Created by 朱继超 on 2022/8/24.
//

import UIKit
import ZSwiftBaseLib
import ProgressHUD

public final class VRCreateRoomViewController: VRBaseViewController {
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var container: VRCreateRoomView = {
        VRCreateRoomView(frame: CGRect(x: 0, y: ZNavgationHeight, width: ScreenWidth, height: ScreenHeight - ZNavgationHeight))
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.container])
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = LanguageManager.localValue(key: "Create Room")
        self.container.createAction = { [weak self] in
            guard let `self` = self else { return }
            print("idx:\(self.container.idx)")
            if self.container.idx <= 0 {
                self.settingSound()
            } else {
                self.view.makeToast("Spatial Audio Room is coming soon".localized())
                self.entryRoom()
            }
        }
    }


}

extension VRCreateRoomViewController {
    
    private func settingSound() {
        let vc = VRSoundEffectsViewController()
        vc.code = self.container.roomInput.code
        vc.type = self.container.idx
        vc.name = self.container.roomInput.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goLive() {
        if self.container.roomInput.name.isEmpty {
            self.view.makeToast("No Room Name".localized(),point: self.view.center, title: nil, image: nil, completion: nil)
        }
        ProgressHUD.show("Create...",interaction: false)
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .createRoom(()), params: ["name":self.container.roomInput.name,"is_private":!self.container.roomInput.code.isEmpty,"password":self.container.roomInput.code,"type":self.container.idx,"allow_free_join_mic":false,"sound_effect":"Social Chat"], classType: VRRoomInfo.self) { info, error in
            ProgressHUD.dismiss()
            if error == nil,info != nil {
                self.view.makeToast("Room Created".localized(), point: self.view.center, title: nil, image: nil, completion: nil)
                let vc = VoiceRoomViewController(info: info!)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")",point: self.view.center, title: nil, image: nil, completion: nil)
            }
        }
    }
    
    private func entryRoom() {
        ProgressHUD.show("Loading".localized(),interaction: false)
        VoiceRoomIMManager.shared?.loginIM(userName: VoiceRoomUserInfo.shared.user?.chat_uid ?? "", token: VoiceRoomUserInfo.shared.user?.im_token ?? "", completion: { userName, error in
            ProgressHUD.dismiss()
            if error == nil {
                Throttler.throttle {
                    self.goLive()
                }
            } else {
                self.view.makeToast("AgoraChat Login failed!",point: self.view.center, title: nil, image: nil, completion: nil)
            }
        })
    }
}
