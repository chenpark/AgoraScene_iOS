//
//  VRSoundEffectsViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/26.
//

import UIKit
import ZSwiftBaseLib

public class VRSoundEffectsViewController: VRBaseViewController {
    
    var code = ""
    
    var name = ""
    
    var type = 0
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var effects: VRSoundEffectsList = {
        VRSoundEffectsList(frame: CGRect(x: 0, y: ZNavgationHeight, width: ScreenWidth, height: ScreenHeight - CGFloat(ZBottombarHeight) - CGFloat(ZTabbarHeight)), style: .plain)
    }()
    
    let done = UIImageView {
        UIImageView(frame: CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - CGFloat(ZTabbarHeight) - 50, width: ScreenWidth, height: 72)).image(UIImage("blur")!)
    }
    
    lazy var toLive: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 30, y: self.done.frame.minY - 10, width: ScreenWidth - 60, height: 50)).title("Go Live", .normal).font(.systemFont(ofSize: 16, weight: .semibold)).setGradient([UIColor(0x219BFF),UIColor(0x345DFF)], [CGPoint(x: 0.25, y: 0.5),CGPoint(x: 0.75, y: 0.5)]).cornerRadius(25).addTargetFor(self, action: #selector(goLive), for: .touchUpInside)
    }()
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.effects,self.done,self.toLive])
//        self.done.addSubview(self.toLive)
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = "Sound Selection"
    }
    
    @objc func goLive() {
        if self.name.isEmpty || self.effects.type.isEmpty {
            self.view.makeToast("param error!")
        }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .createRoom(()), params: ["name":self.name,"is_privacy":!self.code.isEmpty,"password":self.code,"type":self.type,"sound_effect":self.effects.type,"allow_free_join_mic":false], classType: VRRoomInfo.self) { info, error in
            if error == nil {
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
