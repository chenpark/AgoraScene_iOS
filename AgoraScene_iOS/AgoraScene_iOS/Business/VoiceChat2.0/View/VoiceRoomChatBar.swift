//
//  VoiceRoomChatBar.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import UIKit
import ZSwiftBaseLib

@objc public enum VoiceRoomChatBarStyle: Int {
    case normal = 0
    case spatialAudio = 1
}

@objc public enum VoiceRoomChatBarEvents: Int {
    case mic = 0
    case handsUp = 1
    case eq = 2
    case gift = 3
}

@objc public enum VoiceRoomChatBarState: Int {
    case unSelected = 1
    case selected = 2
    case disable = 3
}

public class VoiceRoomChatBar: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    public var events: ((VoiceRoomChatBarEvents) -> ())?
    
    public var creator = false
    
    var handsState: VoiceRoomChatBarState = .unSelected
    
    var micState = false
    
    public var raiseKeyboard: (() -> ())?
    
    public var datas = ["mic","handuphard","eq","sendgift"]
    
    lazy var chatRaiser: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 15, y: 5, width: (100/375.0)*ScreenWidth, height: self.frame.height-10)).backgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)).cornerRadius((self.frame.height-10)/2.0).font(.systemFont(ofSize: 12, weight: .regular)).textColor(UIColor(white: 1, alpha: 0.8), .normal).addTargetFor(self, action: #selector(raiseAction), for: .touchUpInside)
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.height - 10, height: self.frame.height - 10)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    public lazy var toolBar: UICollectionView = {
        UICollectionView(frame: CGRect(x: self.frame.width - (40 * CGFloat(self.datas.count)) - (CGFloat(self.datas.count) - 1)*10 - 15, y: 0, width: 40*(CGFloat(self.datas.count))+(CGFloat(self.datas.count) - 1)*10, height: self.frame.height), collectionViewLayout: self.flowLayout).delegate(self).dataSource(self).backgroundColor(.clear).registerCell(VoiceRoomChatBarCell.self, forCellReuseIdentifier: "VoiceRoomChatBarCell").showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(frame: CGRect,style: VoiceRoomChatBarStyle) {
        self.init(frame: frame)
        if style == .normal {
            self.chatRaiser.isHidden = false
            self.datas = ["mic","handuphard","eq","sendgift"]
        } else {
            self.chatRaiser.isHidden = true
            self.datas = ["mic","handuphard","eq"]
        }
        self.addSubViews([self.chatRaiser,self.toolBar])
        self.chatRaiser.set(image: UIImage("chatraise"), title: "Let's Chat!", titlePosition: .right, additionalSpacing: 5, state: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VoiceRoomChatBar {
    
    @objc func raiseAction() {
        if self.raiseKeyboard != nil {
            self.raiseKeyboard!()
        }
    }
    
    @objc func refresh(event: VoiceRoomChatBarEvents,state: VoiceRoomChatBarState,asCreator: Bool) {
        self.creator = asCreator
        switch event {
        case .mic:
            self.micState = state == .selected ? true:false
            switch state {
            case .unSelected:
                self.datas[0] = "mic"
            case .selected:
                self.datas[0] = "unmic"
            case .disable:
                break
            }
            self.toolBar.reloadItems(at: [IndexPath(row: 0, section: 0)])
        case .handsUp:
            self.handsState = state
            var idx = 0
            for (index,element) in self.datas.enumerated() {
                if element == "handuphard" || element == "handup_dot" || element == "handuphard-1" {
                    idx = index
                    break
                }
            }
            if !asCreator {
                switch state {
                case .unSelected:
                    self.datas[idx] = "handuphard"
                case .selected:
                    self.datas[idx] = "handup_dot"
                case .disable:
                    self.datas[idx] = "handuphard-1"
                }
            } else {
                switch state {
                case .unSelected: self.datas[idx] = "handuphard"
                default: self.datas[idx] = "handup_dot"
                }
            }
            self.toolBar.reloadItems(at: [IndexPath(row: idx, section: 0)])
        default: break
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceRoomChatBarCell", for: indexPath) as? VoiceRoomChatBarCell
        cell?.icon.image = UIImage(self.datas[indexPath.row])
        if indexPath.row == 1,self.creator {
            cell?.redDot.isHidden = false
        } else {
            cell?.redDot.isHidden = true
        }
        return cell ?? VoiceRoomChatBarCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if self.events != nil {
            if indexPath.row == 1,self.handsState != .disable {
                self.events!(VoiceRoomChatBarEvents(rawValue: indexPath.row)!)
            } else {
                self.events!(VoiceRoomChatBarEvents(rawValue: indexPath.row)!)
            }
        }
    }
}
