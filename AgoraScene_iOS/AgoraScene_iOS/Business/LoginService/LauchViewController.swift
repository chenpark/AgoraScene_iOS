//
//  LauchViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import ZSwiftBaseLib
import ProgressHUD

class LauchViewController: UIViewController {

    lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)).image(UIImage(named: "splash_screen")!).contentMode(.scaleAspectFill)
    }()
    
    lazy var reLogin: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth/2.0 - 95, y: ScreenHeight - CGFloat(ZTabbarHeight), width: 190, height: 50)).cornerRadius(25).addTargetFor(self, action: #selector(login), for: .touchUpInside).font(.systemFont(ofSize: 16, weight: .semibold)).title("RetryLogin", .normal).textColor(.white, .normal).setGradient([UIColor(0x0B8AF2),UIColor(0x2753FF)], [CGPoint(x: 0.5, y: 0),CGPoint(x: 0.5, y: 1)])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRoomIMManager.shared?.configIM(appkey: "52117440#955012")
        //MARK: - you can replace request host call this.
//        VoiceRoomBusinessRequest.shared.changeHost(host: <#T##String#>)
        self.login()
        self.view.addSubViews([self.background,self.reLogin])
        self.reLogin.isHidden = true
    }
    
}

extension LauchViewController {
    
    @objc func login() {
        ProgressHUD.show()
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":"avatar3","name":"1234567"],classType:VRUser.self) { [weak self] user, error in
            ProgressHUD.dismiss()
            if error == nil {
                VoiceRoomUserInfo.shared.user = user
                VoiceRoomBusinessRequest.shared.userToken = user?.authorization ?? ""
                self?.entryHome()
                self?.reLogin.isHidden = true
            } else {
                self?.reLogin.isHidden = false
                self?.view.makeToast("\(error?.localizedDescription ?? "")")
            }
        }
    }
    
    @objc func entryHome() {
        let vc = VRRoomsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
