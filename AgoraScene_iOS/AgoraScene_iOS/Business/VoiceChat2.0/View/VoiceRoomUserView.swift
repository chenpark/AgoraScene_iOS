//
//  VoiceRoomUserView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/9.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomUserView: UIView {
    
    lazy var header: VoiceRoomAlertContainer = {
        VoiceRoomAlertContainer(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 56))
    }()
    
    lazy var switchBar: VoiceRoomSwitchBar = {
        VoiceRoomSwitchBar(frame: CGRect(x: 0, y: 16, width: ScreenWidth, height: 40), titles: ["Top Gifters","Audiences"])
    }()
    
    lazy var container: VoiceRoomPageContainer = {
        VoiceRoomPageContainer(frame: CGRect(x: 0, y: self.header.frame.maxY, width: ScreenWidth, height: self.frame.height-self.header.frame.height), viewControllers: [VoiceRoomGiftersViewController.init(),VoiceRoomAudiencesViewController.init()])
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.header,self.switchBar,self.container])
        self.container.scrollClosure = { [weak self] in
            self?.switchBar.moveTo(direction: $0 > 0 ? .right:.left)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
