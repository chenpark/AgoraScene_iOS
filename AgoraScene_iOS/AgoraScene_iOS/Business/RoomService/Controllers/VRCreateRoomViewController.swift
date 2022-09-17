//
//  VRCreateRoomViewController.swift
//  Pods-VoiceRoomBaseUIKit_Example
//
//  Created by 朱继超 on 2022/8/24.
//

import UIKit
import ZSwiftBaseLib

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
        self.navigation.title.text = "Create a room"
        self.container.createAction = { [weak self] in
            guard let `self` = self else { return }
            print("idx:\(self.container.idx)")
            if self.container.idx <= 0 {
                self.settingSound()
            } else {
                self.goLive()
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
            self.view.makeToast("param error!")
        }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .createRoom(()), params: ["name":self.container.roomInput.name,"is_privacy":!self.container.roomInput.code.isEmpty,"password":self.container.roomInput.code,"type":self.container.idx,"allow_free_join_mic":true,"sound_effect":"Social Chat"], classType: VRRoomInfo.self) { info, error in
            if error == nil,info != nil {
                self.entryRoom(room: info)
            } else {
                self.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func entryRoom(room: VRRoomInfo?) {
        VoiceRoomIMManager.shared?.loginIM(userName: VoiceRoomUserInfo.shared.user?.chat_uid ?? "", token: VoiceRoomUserInfo.shared.user?.im_token ?? "", completion: { userName, error in
            if error == nil {
                let vc = VoiceRoomViewController()
                vc.roomInfo = room
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.view.makeToast("\(error?.errorDescription ?? "")")
            }
        })
    }
}
