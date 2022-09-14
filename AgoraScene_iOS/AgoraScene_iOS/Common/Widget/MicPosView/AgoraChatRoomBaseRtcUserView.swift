//
//  AgoraChatRoomBaseRtcUserView.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/30.
//

import UIKit
import SnapKit

public enum AgoraChatRoomBaseUserCellType {
   case AgoraChatRoomBaseUserCellTypeAdd
   case AgoraChatRoomBaseUserCellTypeMute
   case AgoraChatRoomBaseUserCellTypeLock
   case AgoraChatRoomBaseUserCellTypeNormalUser
   case AgoraChatRoomBaseUserCellTypeMuteAndLock
   case AgoraChatRoomBaseUserCellTypeAdmin
   case AgoraChatRoomBaseUserCellTypeAlienNonActive
   case AgoraChatRoomBaseUserCellTypeAlienActive
}

class AgoraChatRoomBaseRtcUserView: UIView {

    public var cellType: AgoraChatRoomBaseUserCellType = .AgoraChatRoomBaseUserCellTypeAdd {
        didSet {
            
            if cellType == .AgoraChatRoomBaseUserCellTypeAlienActive || cellType == .AgoraChatRoomBaseUserCellTypeAlienNonActive {
                self.bgColor = .white
            } else {
                self.bgColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            }
            
            switch cellType {
            case .AgoraChatRoomBaseUserCellTypeAdd:
                self.iconView.isHidden = true
                self.micView.isHidden = true
                self.bgIconView.image = UIImage(named: "icons／solid／add(1)")
            case .AgoraChatRoomBaseUserCellTypeMute:
                self.iconView.isHidden = true
                self.micView.isHidden = false
                self.micView.setState(.forbidden)
                self.bgIconView.image = UIImage(named: "icons／solid／add(1)")
            case .AgoraChatRoomBaseUserCellTypeLock:
                self.iconView.isHidden = true
                self.micView.isHidden = true
                self.bgIconView.image = UIImage(named: "icons／solid／add")
            case .AgoraChatRoomBaseUserCellTypeNormalUser:
                self.iconView.isHidden = false
                self.micView.isHidden = false
                self.micView.setState(.on)
                self.nameBtn.setImage(UIImage(named: ""), for: .normal)
            case .AgoraChatRoomBaseUserCellTypeMuteAndLock:
                self.iconView.isHidden = true
                self.micView.isHidden = false
                self.micView.setState(.forbidden)
                self.bgIconView.image = UIImage(named: "icons／solid／add")
            case .AgoraChatRoomBaseUserCellTypeAdmin:
                self.iconView.isHidden = false
                self.micView.isHidden = false
                self.micView.setState(.on)
                self.nameBtn.setImage(UIImage(named: "fangzhu"), for: .normal)
            case .AgoraChatRoomBaseUserCellTypeAlienNonActive:
                self.iconView.isHidden = false
                self.micView.isHidden = false
                self.micView.setState(.on)
                self.micView.isHidden = true
                self.nameBtn.setImage(UIImage(named: "guanfang"), for: .normal)
                self.coverView.isHidden = false
                self.activeButton.isHidden = false
            case .AgoraChatRoomBaseUserCellTypeAlienActive:
                self.iconView.isHidden = false
                self.micView.isHidden = false
                self.nameBtn.setImage(UIImage(named: "guanfang"), for: .normal)
                self.coverView.isHidden = true
                self.activeButton.isHidden = true
            }
            
        }
    }
    
    public var iconImgUrl: String = "" {
        didSet {
            self.iconView.image = UIImage(named: iconImgUrl)
        }
    }
    
    public var iconWidth: CGFloat = 60~ {
        didSet {
            self.iconView.layer.cornerRadius = (iconWidth / 2.0)~
            self.iconView.layer.masksToBounds = true
            self.iconView.snp.updateConstraints { make in
                make.width.height.equalTo(iconWidth)
            }
        }
    }
    
    public var nameStr: String = "" {
        didSet {
            self.nameBtn.setTitle(nameStr, for: .normal)
        }
    }
    
    public var bgColor: UIColor = .black {
        didSet {
            self.bgView.backgroundColor = bgColor
        }
    }
    
    private var bgView: UIView = UIView()
    private var iconView: UIImageView = UIImageView()
    private var bgIconView: UIImageView = UIImageView()
    private var micView: AgoraMicVolView = AgoraMicVolView()
    private var volImgView: UIImageView = UIImageView()
    private var volBgView: UIView = UIView()
    private var nameBtn: UIButton = UIButton()
    private var coverView: UIView = UIView()
    private var activeButton: UIButton = UIButton()
    
    var clickBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutUI() {
        self.bgView.layer.cornerRadius = 30~;
        self.bgView.layer.masksToBounds = true
        self.bgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.addSubview(self.bgView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        self.bgView.addGestureRecognizer(tap)
        self.bgView.isUserInteractionEnabled = true

        self.bgIconView.image = UIImage(named: "icons／solid／add(1)")
        self.bgIconView.layer.cornerRadius = 15~
        self.bgIconView.layer.masksToBounds = true
        self.addSubview(self.bgIconView)
        
        self.iconView.image = UIImage(named: "longkui")
        self.iconView.layer.cornerRadius = 30~
        self.iconView.layer.masksToBounds = true
        self.addSubview(self.iconView)
        
        self.addSubview(micView)
        
        coverView.backgroundColor = .black
        coverView.alpha = 0.2
        coverView.layer.cornerRadius = 30~
        coverView.layer.masksToBounds = true
        self.addSubview(coverView)
        self.coverView.isHidden = true

        activeButton.backgroundColor = .blue
        activeButton.layer.cornerRadius = 8~
        activeButton.layer.masksToBounds = true
        activeButton.setTitle("active", for: .normal)
        activeButton.setTitleColor(.white, for: .normal)
        activeButton.titleLabel?.font = UIFont.systemFont(ofSize: 9)~
        self.addSubview(activeButton)
        self.activeButton.isHidden = true
        
        self.nameBtn.setTitleColor(.white, for: .normal)
        self.nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11)~
        self.nameBtn.setTitle("jack ma", for: .normal)
        self.nameBtn.isUserInteractionEnabled = false;
        self.addSubview(self.nameBtn)
        
        self.bgView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20~);
            make.width.height.equalTo(60~)
        }
        
        self.bgIconView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.bgView)
            make.width.height.equalTo(30~)
        }
        
        self.iconView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(20~);
            make.width.height.equalTo(60~)
        }
        
        self.micView.snp.makeConstraints { make in
            make.right.equalTo(self.iconView).offset(5~)
            make.width.height.equalTo(18~)
            make.bottom.equalTo(self.iconView.snp.bottom).offset(-5~)
        }
        
        coverView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(iconView)
            make.height.width.equalTo(60~)
        }
        
        activeButton.snp.makeConstraints { make in
            make.centerX.equalTo(iconView)
            make.bottom.equalTo(iconView)
            make.width.equalTo(40~)
            make.height.equalTo(16~)
        }
        
        self.nameBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self.iconView.snp.bottom).offset(10~)
            make.height.equalTo(20~)
        }
    }
   
    @objc private func tapClick(tap: UITapGestureRecognizer) {
        guard let clickBlock = clickBlock else {
            return
        }
        clickBlock()
    }
}
