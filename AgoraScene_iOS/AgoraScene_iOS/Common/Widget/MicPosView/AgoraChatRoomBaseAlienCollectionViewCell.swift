//
//  AgoraChatRoomBaseAlienCollectionViewCell.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/29.
//

import UIKit
import SnapKit

public enum AgoraChatRoomBaseAlienCellType {
   case AgoraChatRoomBaseUserCellTypeActived
   case AgoraChatRoomBaseUserCellTypeNonActived
}

public enum ALIEN_SHOWMIC_TYPE {
    case blue
    case red
    case blueAndRed
    case none
}


class AgoraChatRoomBaseAlienCollectionViewCell: UICollectionViewCell {
    
    private var cornerView: UIView = UIView()
    private var blueAlienView: AgoraChatRoomBaseRtcUserView = AgoraChatRoomBaseRtcUserView()
    private var redAlienView: AgoraChatRoomBaseRtcUserView = AgoraChatRoomBaseRtcUserView()
    private var blueCoverView: UIView = UIView()
    private var redCoverView: UIView = UIView()
    private var linkView: UIImageView = UIImageView()
    private var redActiveButton: UIButton = UIButton()
    private var blueActiveButton: UIButton = UIButton()
    
    public var cellType: AgoraChatRoomBaseAlienCellType = .AgoraChatRoomBaseUserCellTypeNonActived {
        didSet {
            if cellType == .AgoraChatRoomBaseUserCellTypeNonActived {
                blueCoverView.isHidden = false
                redCoverView.isHidden = false
                blueActiveButton.isHidden = false
                redActiveButton.isHidden = false
                blueAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienNonActive
                redAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienNonActive
            } else if cellType == .AgoraChatRoomBaseUserCellTypeActived{
                blueCoverView.isHidden = true
                redCoverView.isHidden = true
                blueActiveButton.isHidden = true
                redActiveButton.isHidden = true
                blueAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienActive
                redAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienActive
            }
            
        }
    }
    
    public var showAlienMicView: ALIEN_TYPE = .none {
        didSet {
            switch showAlienMicView {
            case .blue:
                blueAlienView.showMicView = true
                redAlienView.showMicView = false
            case .red:
                blueAlienView.showMicView = false
                redAlienView.showMicView = true
            case .blueAndRed:
                blueAlienView.showMicView = true
                redAlienView.showMicView = true
            case .none:
                blueAlienView.showMicView = false
                redAlienView.showMicView = false
            default:
                blueAlienView.showMicView = false
                redAlienView.showMicView = false
            }
        }
    }
    
    public var activeVBlock: ((AgoraChatRoomBaseUserCellType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        cornerView.layer.cornerRadius = 33~
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderColor = UIColor.white.cgColor
        cornerView.layer.borderWidth = 1~
        cornerView.backgroundColor = .clear
        self.contentView.addSubview(cornerView)
        
        blueAlienView.iconImgUrl = "blue"
        blueAlienView.nameStr = "Agora Blue"
        blueAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienNonActive
        blueAlienView.activeVBlock = {[weak self] type in
            guard let activeVBlock = self?.activeVBlock else {
                return
            }
            activeVBlock(type)
        }
        self.contentView.addSubview(blueAlienView)
        
        blueCoverView.backgroundColor = .black
        blueCoverView.alpha = 0.2
        blueCoverView.layer.cornerRadius = 30~
        blueCoverView.layer.masksToBounds = true
        self.contentView.addSubview(blueCoverView)

        redAlienView.iconImgUrl = "red"
        redAlienView.nameStr = "Agora Red"
        redAlienView.activeVBlock = {[weak self] type in
            guard let activeVBlock = self?.activeVBlock else {
                return
            }
            activeVBlock(type)
        }
        redAlienView.cellType = .AgoraChatRoomBaseUserCellTypeAlienNonActive
        self.contentView.addSubview(redAlienView)

        linkView.image = UIImage(named: "icons／solid／link")
        self.contentView.addSubview(linkView)
        
        blueAlienView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self.contentView)
            make.width.equalTo(self.contentView).multipliedBy(0.5)
        }
        
        redAlienView.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(self.contentView)
            make.width.equalTo(self.contentView).multipliedBy(0.5)
        }
        
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(17~)
            make.left.equalTo(self.contentView.bounds.size.width / 4.0 - 33~)
            make.right.equalTo(-(self.contentView.bounds.size.width / 4.0 - 33~))
            make.height.equalTo(66~)
        }
        
        linkView.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(cornerView)
        }
        
    }
    
}
