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
            self?.navigationController?.pushViewController(VRSoundEffectsViewController.init(), animated: true)
        }
    }
    


}
