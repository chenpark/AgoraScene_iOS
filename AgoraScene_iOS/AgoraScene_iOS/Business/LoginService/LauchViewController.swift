//
//  LauchViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import ZSwiftBaseLib


class LauchViewController: UIViewController {

    lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)).image(UIImage(named: "splash_screen")!).contentMode(.scaleAspectFill)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRoomIMManager.shared?.configIM(appkey: "52117440#955012")
        //MARK: - you can replace request host call this.
//        VoiceRoomBusinessRequest.shared.changeHost(host: <#T##String#>)
        self.login()
        self.view.addSubview(self.background)
    }
    
}

extension LauchViewController {
    
    func login() {
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":"avatar1","name":"1234"],classType:VRUser.self) { [weak self] user, error in
            if error == nil {
                VoiceRoomUserInfo.shared.user = user
                VoiceRoomBusinessRequest.shared.userToken = user?.authorization ?? ""
                self?.entryHome()
            } else {
                self?.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    @objc func entryHome() {
        let vc = VRRoomsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
