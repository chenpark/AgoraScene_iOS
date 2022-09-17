//
//  VRDisclaimerViewController.swift
//  AgoraScene_iOS
//
//  Created by 朱继超 on 2022/9/17.
//

import UIKit
import ZSwiftBaseLib

public class VRDisclaimerViewController: VRBaseViewController {
    
    let attributeText = NSAttributedString {
        AttributedText("[Agora Chat Room Demo]").font(.systemFont(ofSize: 14, weight: .semibold)).foregroundColor(.darkText)
        AttributedText("('this Product') is a test product provided by Agora. This Product is available for our current and potential customers only, and for them to test the functionality and quality of this Product. This Product is provided neither for commercial nor for public use. Agora enjoys the copyright and ownership of this product. You shall not modify, consolidate, compile, adjust, reverse engineer, sub-license, transfer, sell this Product or infringe the legitimate interests of Agora in any way.\n\n\n").font(.systemFont(ofSize: 12, weight: .regular))
        AttributedText("If you’d like to test this Product, you’re welcome to download, install and use it. Agora hereby grants you a world-wide and royalty-free license to use this Product. This product is provided 'as is' without any express or implicit warranty, including but not limited to guarantees of suitability, suitability for specific purposes, and non-infringement. Whether it is due to any contract, infringement or other forms of conduct related to this Product or the use of this Product or otherwise, Agora shall not be liable for any claims, damages or liabilities arising out of or related to your use of this Product.\n\n\n").font(.systemFont(ofSize: 12, weight: .regular))
        AttributedText("It’s your freedom to choose to test this Product or not. But if you decide to do so, and if you download, install, or use this Product, it means that you confirm and agree that under no circumstances shall Agora be liable for any form of loss or injury caused to yourself or others when you use this Product for any reason, in any manner.\n\n\n").font(.systemFont(ofSize: 12, weight: .regular))
        AttributedText("If you have any query, please feel free to contact").font(.systemFont(ofSize: 12, weight: .regular))
        Link("support@agora.io", url: URL(string: "https://support@agora.io")!).foregroundColor(Color(0x009FFF))
        AttributedText(".").font(.systemFont(ofSize: 12, weight: .regular))
    }
    
    lazy var background: UIImageView = {
        UIImageView(frame: self.view.frame).image(UIImage("roomList")!)
    }()
    
    lazy var textView: UITextView = {
        UITextView(frame: CGRect(x: 24, y: ZNavgationHeight+20, width: ScreenWidth-48, height: ScreenHeight - ZNavgationHeight - 20 - CGFloat(ZBottombarHeight))).attributedText(self.attributeText).isEditable(false)
    }()
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.background,self.textView])
        // Do any additional setup after loading the view.
        self.view.bringSubviewToFront(self.navigation)
        self.navigation.title.text = LanguageManager.localValue(key: "Disclaimer for demo")
    }
    

}
