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

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.userInfo])
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = "Profile"
    }

}

extension VRUserProfileViewController {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
