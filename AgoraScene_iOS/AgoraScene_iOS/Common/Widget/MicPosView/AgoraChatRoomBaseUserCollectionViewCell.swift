//
//  AgoraChatRoomBaseUserCollectionViewCell.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/29.
//

import UIKit



class AgoraChatRoomBaseUserCollectionViewCell: UICollectionViewCell {
    
    private var rtcUserView: AgoraChatRoomBaseRtcUserView = AgoraChatRoomBaseRtcUserView()
    
    public var cellType: AgoraChatRoomBaseUserCellType = .AgoraChatRoomBaseUserCellTypeAdd {
        didSet {
            rtcUserView.cellType = cellType
        }
    }
    
    var user: VRUser? {
        didSet {
            rtcUserView.iconImgUrl = user?.portrait ?? ""
            rtcUserView.nameStr = user?.name ?? "\(self.tag - 200)"
            rtcUserView.volume = user?.volume ?? 0
        }
    }
    
    var clickBlock: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutUI() {
        
        rtcUserView.clickBlock = {[weak self] in
            guard let clickBlock = self?.clickBlock else {
                return
            }
            clickBlock(self?.tag ?? 0)
        }
        self.contentView.addSubview(rtcUserView)
        
        rtcUserView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
    }
}
