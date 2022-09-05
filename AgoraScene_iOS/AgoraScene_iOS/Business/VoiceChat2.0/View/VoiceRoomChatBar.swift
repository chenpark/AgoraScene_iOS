//
//  VoiceRoomChatBar.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomChatBar: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    public var events: ((IndexPath) -> ())?
    
    public var raiseKeyboard: (() -> ())?
    
    public var datas = ["mic","handuphard","eq","sendgift"]
    
    lazy var chatRaiser: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 15, y: 5, width: (111/375.0)*ScreenWidth, height: self.frame.height-10)).backgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)).cornerRadius((self.frame.height-10)/2.0).font(.systemFont(ofSize: 12, weight: .regular)).textColor(.white, .normal)
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
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceRoomChatBarCell", for: indexPath) as? VoiceRoomChatBarCell
        cell?.icon.image = UIImage(self.datas[indexPath.row])
        return cell ?? VoiceRoomChatBarCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if self.events != nil { self.events!(indexPath) }
    }
}
