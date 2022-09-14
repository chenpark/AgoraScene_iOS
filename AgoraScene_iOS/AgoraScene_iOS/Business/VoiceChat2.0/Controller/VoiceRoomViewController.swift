//
//  VoiceRoomViewController.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/6.
//

import UIKit
import SnapKit
import ZSwiftBaseLib

public enum ROLE_TYPE {
    case owner
    case audience
}

class VoiceRoomViewController: VRBaseViewController {
    
    private var headerView: AgoraChatRoomHeaderView!
    private var rtcView: AgoraChatRoomNormalRtcView!
    private var sRtcView: AgoraChatRoom3DRtcView!
    
    private var preView: VMPresentView!
    private var isShowPreSentView: Bool = false
    
    public var entity: VRRoomEntity?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.isHidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigation.isHidden = false
    }
    
}

extension VoiceRoomViewController {
    
    //加载RTC
    private func loadRtc() {
        
    }
    
    //加载IM
    private func loadIM() {
        
    }
    
    //加入房间获取房间详情
    private func requestRoomDetail() {
        
    }
    
    private func layoutUI() {
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "lbg")
        self.view.addSubview(bgImgView)
        
        headerView = AgoraChatRoomHeaderView()
        headerView.entity = entity!
        headerView.completeBlock = {[weak self] action in
            self?.didHeaderAction(with: action)
        }
        self.view.addSubview(headerView)
        
        self.sRtcView = AgoraChatRoom3DRtcView()
        self.view.addSubview(self.sRtcView)
        self.sRtcView.isHidden = entity!.type == 0
        
        self.rtcView = AgoraChatRoomNormalRtcView()
        self.view.addSubview(self.rtcView)
        self.rtcView.isHidden = entity!.type == 1
        
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
            make.height.equalTo(550~);
        }
        
        self.rtcView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(240~);
        }
        
    }
    
    private func didHeaderAction(with action: HEADER_ACTION) {
        if action == .back {
            navigationController?.popViewController(animated: true)
        } else {
            showNoticeView(with: .owner)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isShowPreSentView {
            UIView.animate(withDuration: 0.5, animations: {
                self.preView.snp.updateConstraints { make in
                    make.top.equalTo(ScreenHeight)
                }
            }) { _ in
                self.preView.removeFromSuperview()
                self.preView = nil
                self.sRtcView.isUserInteractionEnabled = true
                self.isShowPreSentView = false
            }
        }
    }
    
    private func showNoticeView(with role: ROLE_TYPE) {
        preView = VMPresentView()
        self.view.addSubview(preView)
        self.isShowPreSentView = true
        self.sRtcView.isUserInteractionEnabled = false
        preView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(450~)
            make.top.equalTo(ScreenHeight)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.preView.snp.updateConstraints { make in
                make.top.equalTo(ScreenHeight - 450~)
            }
        }, completion: nil)
//        let noticeView = VMNoticeView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 220~))
//        noticeView.roleType = .owner
//        noticeView.resBlock = {[weak self] (flag, str) in
//            self?.dismiss(animated: true)
//            guard let str = str else {return}
//
//        }
     //   noticeView.noticeStr = "Welcome to Agora Chat Room 2.0 I am therobot Agora Red. Can you see the robot assistant at the right coner? Click it and experience the new features"
        
      //  let upView = VMAudioSettingView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 450~))
       // upView.action = .kickoff
       // upView.resBlock = {[weak self] type in
//            let test = UIWindow(frame: CGRect(x: 0, y: 300, width: ScreenWidth, height: ScreenHeight*2.0/3.0))
//            test.windowLevel = .alert
//            test.rootViewController = UINavigationController(rootViewController: UIViewController())
//            self?.navigationController?.pushViewController(LauchViewController(), animated: true)
       // }
      //  let vc = VoiceRoomAlertViewController.init(compent: PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: 450~)), custom: upView)
       // self.presentViewController(vc)
        
//        let nav: UINavigationController = UINavigationController(rootViewController: LauchViewController())
//        self.present(nav, animated: true, completion: nil)
//        let vc: LauchViewController = LauchViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        self.preferredContentSize = CGSize(width: ScreenWidth, height: ScreenHeight/2.0)
//        self.present(nav, animated: true, completion: nil)
//        let modal = YXModal()
//        modal.showContentView(upView)
    }
}
