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
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        if collectionView == nil {
            SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
            layoutUI()
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
            let cell: AgoraChatRoomBaseUserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: nIdentifier, for: indexPath) as! AgoraChatRoomBaseUserCollectionViewCell
            cell.tag = indexPath.item + 200
            /*
             0: 正常 1: 闭麦 2: 禁言 3: 锁麦 4: 锁麦和禁言 -1: 空闲
             */
            if let mic_info = micInfos?[indexPath.item] {
                cell.user = mic_info.member
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
                
            } else {
                cell.cellType = .AgoraChatRoomBaseUserCellTypeAdd
            }
            
            cell.clickBlock = {[weak self] tag in
                print("------\(tag)")
                guard let block = self?.clickBlock else {return}
                block(cell.cellType, tag)
            }

            return cell
        } else {
            let cell: AgoraChatRoomBaseAlienCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: aIdentifier, for: indexPath) as! AgoraChatRoomBaseAlienCollectionViewCell
            if let mic_info = micInfos?[indexPath.item] {
                cell.cellType = mic_info.status == 5 ? .AgoraChatRoomBaseUserCellTypeActived : .AgoraChatRoomBaseUserCellTypeNonActived
            }
            cell.activeVBlock = {[weak self] type in
                guard let block = self?.clickBlock else {return}
                block(type, 0)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
