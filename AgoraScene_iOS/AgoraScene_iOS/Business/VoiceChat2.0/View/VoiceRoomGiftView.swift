//
//  VoiceRoomGiftView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/31.
//

import UIKit
import ZSwiftBaseLib

public class VoiceRoomGiftView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    public var gifts = [VoiceRoomGiftEntity]()

    private var lastOffsetY = CGFloat(0)
        
    public lazy var giftList: UITableView = {
        UITableView(frame: CGRect(x: 15, y: 0, width: self.frame.width-30, height: self.frame.height), style: .plain).tableFooterView(UIView()).separatorStyle(.none).registerCell(VoiceRoomGiftCell.self, forCellReuseIdentifier: "VoiceRoomGiftCell").showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false).delegate(self).dataSource(self).backgroundColor(.clear)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.giftList)
        self.giftList.isScrollEnabled = false
        self.giftList.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VoiceRoomGiftView {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.gifts.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.giftList.frame.width/5.0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VoiceRoomGiftCell") as? VoiceRoomGiftCell
        if cell == nil {
            cell = VoiceRoomGiftCell(style: .default, reuseIdentifier: "VoiceRoomGiftCell")
        }
        cell?.gift = self.gifts[safe:indexPath.row]
        return cell ?? VoiceRoomGiftCell()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.giftList.indexPathForRow(at: scrollView.contentOffset) ?? IndexPath(row: 0, section: 0)
        let cell = self.giftList.cellForRow(at: indexPath)
        let offsetY = scrollView.contentOffset.y
        if offsetY - self.lastOffsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.alpha = 0.35
                cell?.contentView.transform = CGAffineTransform(scaleX: 0.618, y: 0.618)
            }
        }
        self.lastOffsetY = offsetY
    }

}
