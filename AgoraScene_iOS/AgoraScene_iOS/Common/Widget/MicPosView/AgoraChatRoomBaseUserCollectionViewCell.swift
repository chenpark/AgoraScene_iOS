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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutUI() {
        
        self.contentView.addSubview(rtcUserView)
        
        rtcUserView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
    }
}
