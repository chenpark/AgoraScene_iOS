//
//  VRSoundEffectsViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/26.
//

import UIKit
import ZSwiftBaseLib

public class VRSoundEffectsViewController: VRBaseViewController {
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var effects: VRSoundEffectsList = {
        VRSoundEffectsList(frame: CGRect(x: 0, y: ZNavgationHeight, width: ScreenWidth, height: ScreenHeight - CGFloat(ZBottombarHeight) - CGFloat(ZTabbarHeight)), style: .plain)
    }()
    
    let done = UIButton {
        UIButton(type: .custom).frame(CGRect(x: 0, y: ScreenHeight - CGFloat(ZBottombarHeight) - CGFloat(ZTabbarHeight) - 50, width: ScreenWidth, height: 72)).backgroundImg(UIImage("blur")!, .normal)
        UIButton(type: .custom).frame(CGRect(x: 30, y: 10, width: ScreenWidth - 60, height: 50)).title("Go Live", .normal).font(.systemFont(ofSize: 16, weight: .semibold)).setGradient([UIColor(0x219BFF),UIColor(0x345DFF)], [CGPoint(x: 0.25, y: 0.5),CGPoint(x: 0.75, y: 0.5)]).cornerRadius(25).addTargetFor(VRSoundEffectsViewController.self, action: #selector(goLive), for: .touchUpInside)
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.background,self.effects,self.done])
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = "Sound Selection"
    }
    
    @objc func goLive() {
        
    }
    
}
