//
//  AgoraChatRoom3DRtcView.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/30.
//

import UIKit

private enum TouchState {
    case began
    case moved
    case ended
}

class AgoraChatRoom3DRtcView: UIView {
    private var collectionView: UICollectionView!
    private let vIdentifier = "3D"
    private let nIdentifier = "normal"
    private var rtcUserView: AgoraChatRoom3DMoveUserView = AgoraChatRoom3DMoveUserView()
    
    private var _lastPointAngle: Double = 0
    private var lastPoint:CGPoint = .zero
    fileprivate var sendTS: CLongLong = 0
    private var lastPrePoint: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: 275~)
    private var lastCenterPoint: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: 275~)
    private var lastMovedPoint: CGPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: 275~)
    private var touchState: TouchState = .began
    public override func draw(_ rect: CGRect) {
        // Drawing code
        SwiftyFitsize.reference(width: 375, iPadFitMultiple: 0.6)
        layoutUI()
    }

    private func layoutUI() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.bounds.size.width / 4.0, height: 120)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(AgoraChatRoom3DUserCollectionViewCell.self, forCellWithReuseIdentifier: vIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: nIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = false
        
        self.collectionView = collectionView
        self.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalTo(self);
        }
        
        self.addSubview(rtcUserView)
        rtcUserView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.height.equalTo(150~)
        }
        
        self.isUserInteractionEnabled = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taptap))
        self.addGestureRecognizer(tap)
        
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.addGestureRecognizer(pan)
    }
    
    
}

extension AgoraChatRoom3DRtcView {
    
    @objc private  func taptap( tap: UIGestureRecognizer) {
        
        var location = tap.location(in: self)
        
        //处理边界
        if location.x <= 75~ {
            location.x = 75~
        }
        
        if location.y <= 75~ {
            location.y = 75~
        }
        
        if location.x >= self.bounds.size.width - 75~ {
            location.x = self.bounds.size.width - 75~
        }
        
        
        if location.y >= self.bounds.size.height - 75~ {
            location.y = self.bounds.size.height - 75~
        }
        
        let angle = getAngle(location, preP: lastCenterPoint);
        self.rtcUserView.angle = angle - _lastPointAngle
        UIView.animate(withDuration: 3, delay: 0) { [self] in
            self.rtcUserView.center = CGPoint(x: location.x, y: location.y)
        }

        if  angle == _lastPointAngle {return}
        _lastPointAngle = angle
        lastCenterPoint = self.rtcUserView.center
    }
    
    @objc private func pan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self)
        
        var moveCenter = CGPoint(x: self.rtcUserView.center.x + translation.x, y: self.rtcUserView.center.y + translation.y)
        
        //处理边界
        if moveCenter.x <= 75~ {
            moveCenter.x = 75~
        }
        
        if moveCenter.y <= 75~ {
            moveCenter.y = 75~
        }
        
        if moveCenter.x >= self.bounds.size.width - 75~ {
            moveCenter.x = self.bounds.size.width - 75~
        }
        
        if moveCenter.y >= self.bounds.size.height - 75~ {
            moveCenter.y = self.bounds.size.height - 75~
        }
        
        self.rtcUserView.center = CGPoint(x: moveCenter.x, y: moveCenter.y)
        pan.setTranslation(.zero, in: self)
        
        if getCurrentTimeStamp() - sendTS < 300 {return}
        let angle = getAngle(self.rtcUserView.center, preP: self.lastCenterPoint);
        if abs(angle - _lastPointAngle) < 0.2 {
            return
        }
        self.rtcUserView.angle = angle - _lastPointAngle
        if  angle == _lastPointAngle {return}
        _lastPointAngle = angle
        lastCenterPoint = self.rtcUserView.center
        sendTS = getCurrentTimeStamp()
    }
    
    fileprivate func getAngle(_ curP: CGPoint, preP: CGPoint) -> Double {
        let changeX = curP.x - preP.x
        let changeY = curP.y - preP.y
        let radina = atan2(changeY, changeX)
        let angle = 180.0 / Double.pi * radina
        return ((angle + 90)) / 180.0 * Double.pi
    }
    
    fileprivate func getCurrentTimeStamp() -> CLongLong{
        // 当前时间戳
        let timestamp = Date().timeIntervalSince1970
        // 毫秒级时间戳
        let timeStamp_now = CLongLong(round(timestamp*1000))
        return timeStamp_now
    }
}

extension AgoraChatRoom3DRtcView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if indexPath.item != 3  {
            return CGSize(width: self.bounds.size.width / 3.0, height: 150~)
        } else {
            return CGSize(width: self.bounds.size.width, height: 250~)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item != 3 {
            let cell: AgoraChatRoom3DUserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: vIdentifier, for: indexPath) as! AgoraChatRoom3DUserCollectionViewCell
            switch indexPath.item {
            case 0:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeAdd
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeDown
            case 1:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeMute
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeUp
            case 2:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeMuteAndLock
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeDown
            case 4:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeAdmin
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeUp
            case 5:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeNormalUser
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeDown
            default:
                cell.cellType = .AgoraChatRoomBaseUserCellTypeNormalUser
                cell.directionType = .AgoraChatRoom3DUserDirectionTypeUp
            }
            return cell
        } else {
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: nIdentifier, for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
