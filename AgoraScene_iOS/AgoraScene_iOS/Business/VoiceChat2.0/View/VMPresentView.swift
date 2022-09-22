//
//  VMPresentView.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/8.
//

import UIKit
import SnapKit
class VMPresentView: UIView {
    private var screenSize: CGSize = UIScreen.main.bounds.size
    private var scrollView: UIScrollView = UIScrollView()
    private var audioSetView: VMAudioSettingView = VMAudioSettingView()
    private var eqView: VMEQSettingView = VMEQSettingView()
    public var roomInfo: VRRoomInfo?
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .white
        layoutUI()
    }
    
    private func layoutUI() {
        scrollView.contentSize = CGSize(width: screenSize.width * 2, height: 0)
        scrollView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: self.bounds.size.height)
        self.addSubview(scrollView)
        scrollView.isScrollEnabled = false
        
        audioSetView.backgroundColor = .white
        audioSetView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: self.bounds.size.height)
        if let type = roomInfo?.room?.type {
            audioSetView.isPrivate = type == 1
        } else {
            audioSetView.isPrivate = false
        }
        audioSetView.isAudience = roomInfo?.room?.use_robot ?? false
        audioSetView.resBlock = {[weak self] type in
            self?.scrollView.isScrollEnabled = true
            self?.eqView.settingType = type
            self?.scrollView.setContentOffset(CGPoint(x: (self?.screenSize.width)!, y: 0), animated: true)
        }
        scrollView.addSubview(audioSetView)
        
        eqView.backgroundColor = .white
        eqView.frame = CGRect(x: screenSize.width, y: 0, width: screenSize.width, height: self.bounds.size.height)
        eqView.resBlock = {[weak self] type in
            self?.eqView.settingType = type
        }
        eqView.backBlock = {[weak self] in
            self?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self?.scrollView.isScrollEnabled = false
        }
        scrollView.addSubview(eqView)
    }

}
