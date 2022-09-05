//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import UIKit
import ZSwiftBaseLib
//public enum

public class VoiceRoomAlertViewController: UIViewController,PresentedViewType {
    
    public var presentedViewComponent: PresentedViewComponent
    
    var customView: UIView?

    var limitHeight = ScreenHeight/2.0

    lazy var container: UIView = {
        VoiceRoomAlertContainer(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 56)).cornerRadius(20, [.topLeft,.topRight], .white, 0).backgroundColor(.white)
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.presentedViewComponent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: ScreenHeight/2.0))
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presentedViewComponent = PresentedViewComponent(contentSize: CGSize(width: ScreenWidth, height: ScreenHeight/2.0))
        super.init(coder: aDecoder)
    }
    
    public convenience init(compent: PresentedViewComponent,custom: UIView) {
        self.init()
        self.presentedViewComponent = compent
        self.presentedViewComponent.contentSize = CGSize(width: compent.contentSize.width, height: compent.contentSize.height+56)
        self.customView = custom
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.container,self.customView!])
    }

}
