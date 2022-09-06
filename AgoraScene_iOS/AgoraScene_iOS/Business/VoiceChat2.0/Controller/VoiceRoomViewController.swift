//
//  VoiceRoomViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import SnapKit

class VoiceRoomViewController: VRBaseViewController {
    
    private var headerView: AgoraChatRoomHeaderView!
    private var rtcView: AgoraChatRoomNormalRtcView!
    private var sRtcView: AgoraChatRoom3DRtcView!
    
    private var _lastPointAngle: Double = 0
    private var lastPoint:CGPoint = .zero
    fileprivate var sendTS: CLongLong = 0
    private var lastPrePoint: CGPoint = .zero
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.isHidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "lbg")
        self.view.addSubview(bgImgView)
        
        headerView = AgoraChatRoomHeaderView()
        self.view.addSubview(headerView)
        
        self.sRtcView = AgoraChatRoom3DRtcView()
        self.view.addSubview(self.sRtcView)
        
        self.rtcView = AgoraChatRoomNormalRtcView()
        self.view.addSubview(self.rtcView)
        
        bgImgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.view);
        }
        
        self.headerView.snp.makeConstraints { make in
            make.left.top.right.equalTo(self.view);
            make.height.equalTo(140~);
        }
        
        self.sRtcView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(450~);
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigation.isHidden = false
    }
}
