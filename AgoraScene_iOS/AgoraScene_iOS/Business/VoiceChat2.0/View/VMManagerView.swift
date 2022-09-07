//
//  VMManagerView.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/7.
//

import UIKit
import ZSwiftBaseLib

public enum ADMIN_ACTION {
    case invite
    case kickoff
}

class VMManagerView: UIView {

    private var lineImgView: UIImageView = UIImageView()
    private var bgView: UIView = UIView()
    private var addView: UIImageView = UIImageView()
    private var iconView: UIImageView = UIImageView()
    private var nameLabel: UILabel = UILabel()
    private var roleBtn: UIButton = UIButton()
    private var lineView: UIView = UIView()
    private var sepView: UIView = UIView()
    private var sep2View: UIView = UIView()
    private var inviteBtn: UIButton = UIButton()
    private var muteBtn: UIButton = UIButton()
    private var lockBtn: UIButton = UIButton()
    private var kfBtn: UIButton = UIButton()
    
    public var action: ADMIN_ACTION = .invite {
        didSet {
            if action == .invite {
                kfBtn.isHidden = true
                inviteBtn.isHidden = false
                lockBtn.setTitle("Lock", for: .normal)
                iconView.isHidden = true
                roleBtn.isHidden = true
            } else {
                kfBtn.isHidden = false
                inviteBtn.isHidden = true
                lockBtn.setTitle("Upstage", for: .normal)
                iconView.isHidden = false
                roleBtn.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        
        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20.0, height: 20.0))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = path.cgPath
        self.layer.mask = layer
        
        lineImgView.frame = CGRect(x: ScreenWidth / 2.0 - 20~, y: 8~, width: 40~, height: 4~)
        lineImgView.image = UIImage(named: "pop_indicator")
        self.addSubview(lineImgView)
        
        bgView.frame = CGRect(x: ScreenWidth / 2 - 32~, y: 40~, width: 64~, height: 64~)
        bgView.backgroundColor = .lightGray
        bgView.layer.cornerRadius = 32~
        bgView.layer.masksToBounds = true
        self.addSubview(bgView)
        
        addView.frame = CGRect(x: ScreenWidth / 2 - 11~, y: 61~, width: 22~, height: 22~)
        addView.image = UIImage(named: "icons／solid／add(1)")
        self.addSubview(addView)
        
        iconView.frame = CGRect(x: ScreenWidth / 2 - 32~, y: 40~, width: 64~, height: 64~)
        iconView.image = UIImage(named: "longkui")
        iconView.layer.cornerRadius = 32~
        iconView.layer.masksToBounds = true
        self.addSubview(iconView)
        iconView.isHidden = true
        
        nameLabel.frame = CGRect(x: ScreenWidth/2.0 - 100~, y: 110~, width: 200~, height: 20)
        nameLabel.text = "hello world"
        nameLabel.textAlignment = .center
        self.addSubview(nameLabel)
        
        roleBtn.frame = CGRect(x: ScreenWidth/2.0 - 50~, y: 135~, width: 100~, height: 20)
        roleBtn.setImage(UIImage(named: "fangzhu"), for: .normal)
        roleBtn.setTitle("host", for: .normal)
        roleBtn.setTitleColor(.black, for: .normal)
        roleBtn.font(UIFont.systemFont(ofSize: 11))
        self.addSubview(roleBtn)
        self.roleBtn.isHidden = true
        
        lineView.frame = CGRect(x: 0, y: 160~, width: ScreenWidth, height: 1)
        lineView.backgroundColor = .separator
        self.addSubview(lineView)

        inviteBtn.frame = CGRect(x: 20, y: 170~, width: ScreenWidth / 3.0 - 40, height: 40~)
        inviteBtn.setTitleColor(.white, for: .normal)
        inviteBtn.setTitle("invite", for: .normal)
        inviteBtn.font(UIFont.systemFont(ofSize: 14))
        self.addSubview(inviteBtn)
        // gradient
        let gl: CAGradientLayer = CAGradientLayer()
        gl.startPoint = CGPoint(x: 0.18, y: 0)
        gl.endPoint = CGPoint(x: 0.66, y: 1)
        gl.colors = [UIColor(red: 33/255.0, green: 155/255.0, blue: 1, alpha: 1).cgColor, UIColor(red: 52/255.0, green: 93/255.0, blue: 1, alpha: 1).cgColor]
        gl.locations = [0, 1.0]
        inviteBtn.layer.cornerRadius = 20~;
        inviteBtn.layer.masksToBounds = true;
        gl.frame = inviteBtn.bounds;
        inviteBtn.layer.addSublayer(gl)
        
        kfBtn.frame = CGRect(x: 20, y: 170~, width: ScreenWidth / 3.0 - 40, height: 40~)
        kfBtn.setTitleColor(.blue, for: .normal)
        kfBtn.setTitle("Kick Off Stage", for: .normal)
        kfBtn.font(UIFont.systemFont(ofSize: 14))
        self.addSubview(kfBtn)
        kfBtn.isHidden = true
        
        muteBtn.frame = CGRect(x: ScreenWidth / 3.0 + 20, y: 170~, width: ScreenWidth / 3.0 - 40, height: 40~)
        muteBtn.setTitleColor(.blue, for: .normal)
        muteBtn.setTitle("Mute", for: .normal)
        muteBtn.font(UIFont.systemFont(ofSize: 14))
        self.addSubview(muteBtn)
        
        lockBtn.frame = CGRect(x: ScreenWidth / 3.0 * 2 + 20, y: 170~, width: ScreenWidth / 3.0 - 40, height: 40~)
        lockBtn.setTitleColor(.blue, for: .normal)
        lockBtn.setTitle("Lock", for: .normal)
        lockBtn.font(UIFont.systemFont(ofSize: 14))
        self.addSubview(lockBtn)
        
        sepView.frame = CGRect(x: ScreenWidth / 3.0, y: 180~, width: 1, height: 20~)
        sepView.backgroundColor = .separator
        self.addSubview(sepView)
        
        sep2View.frame = CGRect(x: ScreenWidth / 3.0 * 2, y: 180~, width: 1, height: 20~)
        sep2View.backgroundColor = .separator
        self.addSubview(sep2View)
    }

}
