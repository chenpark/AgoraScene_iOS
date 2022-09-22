//
//  LauchViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import ZSwiftBaseLib
import ProgressHUD

final class LauchViewController: UIViewController {
    
    @UserDefault("VoiceRoomFirstLaunch", defaultValue: false) var first
    
    @UserDefault("VoiceRoomUserName", defaultValue: "") var userName
    
    @UserDefault("VoiceRoomUserName", defaultValue: "") var userAvatar
    
    var name: String {
        var firstName = ["李","王","张","刘","陈","杨","赵","黄","周","吴","徐","孙","胡","朱","高","林","何","郭","马","罗"]
        var lastName = ["小明","小虎","小芳","小红","小雨","小雪","小鹏","小双","小彤","小晗","阿花","阿杰","阿鹏","阿飞","阿青","阿永","阿超","阿伟","阿信","阿华"]
        if NSLocale.preferredLanguages.first!.hasPrefix("en") {
            firstName = ["James","Robert","John","Michael","David","William","Richard","Joseph","Thomas","Charles","Mary","Patricia","Jennifer","Linda","Elizabeth","Barbara","Susan","Jessica","Sarah","Karen"]
            lastName = ["Smith","Johnson","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Hernandez","Lopez","Gonzalez","Wilson","Anderson","Taylor","Moore","Jackson","Martin","Lee","Perez"]
        }
        return (firstName.randomElement() ?? "") + (lastName.randomElement() ?? "")
    }
    
    var avatars: [String] {
        ["avatar1","avatar2","avatar3","avatar4","avatar5","avatar6","avatar7","avatar8","avatar9","avatar10","avatar11","avatar12","avatar13","avatar14","avatar15","avatar16","avatar17","avatar18"]
    }
    
    
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
        var userRandomName = "123"
        var avatar = "avatar1"
        if self.first == false {
            userRandomName = self.name
            avatar = self.avatars.randomElement() ?? avatar
            self.userName = userRandomName
            self.userAvatar = avatar
        } else {
            userRandomName = self.userName
            avatar = self.userAvatar
        }
        VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["deviceId":UIDevice.current.deviceUUID,"portrait":avatar,"name":userRandomName],classType:VRUser.self) { [weak self] user, error in
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
