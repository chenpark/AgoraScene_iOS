//
//  VRCreateRoomView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/25.
//

import UIKit
import ZSwiftBaseLib

public class VRCreateRoomView: UIView,HorizontalCardsDelegate,HorizontalCardsDataSource {
    
    private let datas = [["title":LanguageManager.localValue(key: "Chat Room"),"detail":"Multi-audio chat scenario where anyone can unmute their mic and speak\nCo-Watch / Team Chat / Gaming Buddy Chat","image":"chat_room"],["title":LanguageManager.localValue(key: "Spatial audio chat Mode Room"),"detail":"Spatial audio chat room mode\nCo-Watch / Team Chat / Gaming Buddy Cha","image":"sa_mode"]]
//    ["title":"Karaoke","detail":"Multi-audio chat scenario where anyone can unmute their mic and speak\nCo-Watch / Team Chat / Gaming Buddy Chat","image":"karaoke"]
    
    var velocity = CGPoint.zero
    
    /// 0 normal 1 sp
    var idx = 0
    
    let cardHeight = (200/315.0)*(ScreenWidth-60)
    
    var lastOffset: CGPoint = .zero
    
    var createAction: (()->())?

    lazy var menuBar: VRRoomMenuBar = {
        VRRoomMenuBar(frame: CGRect(x: 20, y: 0, width: ScreenWidth-40, height: 42), items: VRRoomMenuBar.entities1, indicatorImage: UIImage("indicator")!,indicatorFrame: CGRect(x: 0, y: 42 - 8, width: 14, height: 8)).backgroundColor(.clear)
    }()
    
    lazy var audioEffectCards: HorizontalCardsView = {
        let cards = HorizontalCardsView(frame: CGRect(x: 0, y: self.menuBar.frame.maxY + 10, width: ScreenWidth, height: self.cardHeight))
        cards.dataSource = self
        cards.delegate = self
        cards.cardSpacing = 20
        cards.insets = UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
        return cards
    }()
    
    lazy var roomInput: VRCreateRoomInputView = {
        VRCreateRoomInputView(frame: CGRect(x: 0, y: self.audioEffectCards.frame.maxY + 15, width: ScreenWidth, height: self.frame.height - self.audioEffectCards.frame.maxY - 30))
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.menuBar,self.audioEffectCards,self.roomInput])
        self.menuBar.selectClosure = { [weak self] in
            self?.idx = $0.row
            self?.audioEffectCards.collectionView.scrollToItem(at: $0, at: .centeredHorizontally, animated: true)
            if $0.row > 0 {
                self?.roomInput.create.setTitle(LanguageManager.localValue(key: "Go Live"), for: .normal)
            } else {
                self?.roomInput.create.setTitle(LanguageManager.localValue(key: "Next"), for: .normal)
            }
        }
        self.roomInput.action = { [weak self] in
            self?.create()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VRCreateRoomView {
    
    private func create() {
        if self.createAction != nil {
            self.createAction!()
        }
    }
    
    public func horizontalCardsView(_: HorizontalCardsView, scrollIndex: Int) {
        self.idx = scrollIndex
        self.menuBar.dataSource.forEach { $0.selected = false }
        self.menuBar.dataSource[safe: scrollIndex]?.selected = true
        self.menuBar.menuList.reloadData()
        self.menuBar.menuList.scrollToItem(at: IndexPath(row: scrollIndex, section: 0), at: .right, animated: true)
    }
    
    public func horizontalCardsView(_: HorizontalCardsView, didSelectItemAtIndex index: Int) {
        
    }
    
    public func horizontalCardsViewNumberOfItems(_: HorizontalCardsView) -> Int {
        2
    }
    
    public func horizontalCardsView(_: HorizontalCardsView, viewForIndex index: Int) -> HorizontalCardView {
        let card = HorizontalCardView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 40, height: self.cardHeight)).backgroundColor(.cyan).cornerRadius(25)
        guard let title = self.datas[index]["title"],let detail = self.datas[index]["detail"],let image = UIImage(self.datas[index]["image"]!) else { return card }
        return VRSoundTypeCard(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 40, height: self.cardHeight),title: title,note: detail,background: image).cornerRadius(25)
    }
   
}
