//
//  VRUserProfileViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/25.
//

import UIKit
import ZSwiftBaseLib

public final class VRUserProfileViewController: VRBaseViewController {

        
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var userInfo: VRUserInfoView = {
        VRUserInfoView(frame: CGRect(x: 20, y: ZNavgationHeight+10, width: ScreenWidth-40, height: (110/335.0)*(ScreenWidth - 40))).cornerRadius(10)
    }()
    
    lazy var disclaimerView: VoiceRoomDisclaimerView = {
        VoiceRoomDisclaimerView(frame: CGRect(x: 20, y: self.userInfo.frame.maxY+20, width: ScreenWidth-40, height: 80)).cornerRadius(10)
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.userInfo,self.disclaimerView])
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = LanguageManager.localValue(key: "Profile")
        self.disclaimerView.tapClosure = { [weak self] in
            self?.pushDisclaimer()
        }
        self.userInfo.editFinished = { [weak self] in
            self?.changeUserName(userName: $0)
        }
    }

}

extension VRUserProfileViewController {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func pushDisclaimer() {
        self.navigationController?.pushViewController(VRDisclaimerViewController(), animated: true)
    }
    
    private func changeUserName(userName: String) {
        //VoiceRoomBusinessRequest.shared.sendPOSTRequest(api: .modifyRoomInfo(roomId: <#T##String#>), params: <#T##Dictionary<String, Any>#>, classType: <#T##Convertible.Protocol#>, callBack: <#T##((Convertible?, Error?) -> Void)##((Convertible?, Error?) -> Void)##(Convertible?, Error?) -> Void#>)
    }
}
