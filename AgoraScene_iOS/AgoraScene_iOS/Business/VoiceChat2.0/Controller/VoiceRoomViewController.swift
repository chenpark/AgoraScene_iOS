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
    
    private var _lastPointAngle: Double = 0
    private var lastPoint:CGPoint = .zero
    fileprivate var sendTS: CLongLong = 0
    private var lastPrePoint: CGPoint = .zero
    private var preView: VMPresentView!
    private var isShowPreSentView: Bool = false
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
        headerView.completeBlock = {[weak self] action in
            self?.didHeaderAction(with: action)
        }
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
}

extension VoiceRoomViewController {
    func didHeaderAction(with action: HEADER_ACTION) {
        showNoticeView(with: .owner)
    }
    
    func showNoticeView(with role: ROLE_TYPE) {
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
