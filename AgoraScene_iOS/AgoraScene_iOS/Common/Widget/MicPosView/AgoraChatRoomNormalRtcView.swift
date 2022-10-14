//
//  AgoraChatRoomRtcView.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/29.
//

import UIKit
import SnapKit

class AgoraChatRoomNormalRtcView: UIView {

    private var collectionView: UICollectionView!
    private let nIdentifier = "normal"
    private let aIdentifier = "alien"
    
    var clickBlock: ((AgoraChatRoomBaseUserCellType, Int) -> Void)?
    
    var micInfos: [VRRoomMic]? {
        didSet {
            guard let _ = collectionView else {
                return
            }
            collectionView.reloadData()
        }
    }
    
    var showAlienMicView: ALIEN_TYPE = .none {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        if collectionView == nil {
            SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
            layoutUI()
        }
    }
    
    public func updateVolume(with uid: String, vol: Int) {
        /**
         1.根据uid来判断是哪个cell需要更新音量
         2.更新音量
         */
        guard let micInfos = micInfos else {
            return
        }
        for i in micInfos {
            guard let member = i.member else {return}
            guard let cur_uid = member.uid else {return}
            if cur_uid == uid {
                guard let mic_index = member.mic_index else {return}
                let indexPath: IndexPath = IndexPath(item: mic_index, section: 0)
                let cell: AgoraChatRoomBaseUserCollectionViewCell = collectionView.cellForItem(at: indexPath) as! AgoraChatRoomBaseUserCollectionViewCell
                cell.refreshVolume(vol: vol)
            }
        }
    }

    private func layoutUI() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.bounds.size.width / 4.0, height: 120~)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(AgoraChatRoomBaseUserCollectionViewCell.self, forCellWithReuseIdentifier: nIdentifier)
        collectionView.register(AgoraChatRoomBaseAlienCollectionViewCell.self, forCellWithReuseIdentifier: aIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        self.collectionView = collectionView
        self.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalTo(self);
        }
    }
}

extension AgoraChatRoomNormalRtcView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if indexPath.item < 6 {
            return CGSize(width: self.bounds.size.width / 4.0, height: 120~)
        } else {
            return CGSize(width: self.bounds.size.width / 2.0, height: 120~)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < 6 {
            let cell:   AgoraChatRoomBaseUserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: nIdentifier, for: indexPath) as! AgoraChatRoomBaseUserCollectionViewCell
            cell.tag = indexPath.item + 200
            cell.clickBlock = {[weak self] tag in
                print("------\(tag)-----\(cell.tag))")
                guard let block = self?.clickBlock else {return}
                block(cell.cellType, tag)
            }
            /*
             0: 正常 1: 闭麦 2: 禁言 3: 锁麦 4: 锁麦和禁言 -1: 空闲
             */
            if let mic_info = micInfos?[indexPath.item] {
                let user: VRUser = mic_info.member ?? VRUser()
                user.mic_index = indexPath.item
                switch mic_info.status {
                case -1:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeAdd
                case 0:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeNormalUser
                case 1:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeMute
                case 2:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeForbidden
                case 3:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeLock
                case 4:
                    cell.cellType = .AgoraChatRoomBaseUserCellTypeMuteAndLock
                default:
                    break
                }
                cell.refreshUser(with: user)
                
            } else {
                cell.cellType = .AgoraChatRoomBaseUserCellTypeAdd
            }
            return cell
        } else {
            let cell: AgoraChatRoomBaseAlienCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: aIdentifier, for: indexPath) as! AgoraChatRoomBaseAlienCollectionViewCell
            if let mic_info = micInfos?[indexPath.item] {
                cell.cellType = mic_info.status == 5 ? .AgoraChatRoomBaseUserCellTypeActived : .AgoraChatRoomBaseUserCellTypeNonActived
                cell.showAlienMicView = self.showAlienMicView
            }
            
            cell.clickVBlock = {
                guard let clickBlock = self.clickBlock else {return}
                clickBlock(.AgoraChatRoomBaseUserCellTypeAlienActive, 0)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("---点击--\(indexPath.item)----")
    }
}
