//
//  VoiceRoomChatView.swift
//  VoiceRoomBaseUIKit-VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import UIKit
import ZSwiftBaseLib

let chatViewWidth = ScreenWidth*(287/375.0)

let json1 = ["userName":"LG","content":"手机吊饰的及哦啊江山帝景爱搜较激动我按实际氨基酸asdasdasdasdasdasdasdasdasdsad地欧萨记得加"]

let json2 = ["userName":"Apple","content":"我看看奥术大师多"]

public class VoiceRoomChatView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var likeAction: ((UIButton)->())?
    
    private var lastOffsetY = CGFloat(0)
    
    private var cellOffset = CGFloat(0)
    
    var messages: [VoiceRoomChatEntity]? = [VoiceRoomChatEntity]()
    
    lazy var chatView: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: chatViewWidth, height: self.frame.height), style: .plain).delegate(self).dataSource(self).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).registerCell(VoiceRoomChatCell.self, forCellReuseIdentifier: "VoiceRoomChatCell").showsVerticalScrollIndicator(false)
    }()
    
    lazy var likeView: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-53, y: self.frame.height - 43, width: 38, height: 38)).addTargetFor(self, action: #selector(toLike(_:)), for: .touchUpInside)
    }()
    
    lazy var emitter: VoiceRoomPraiseEmitterView = {
        VoiceRoomPraiseEmitterView(frame: CGRect(x: ScreenWidth-80, y: -20, width: 80, height: self.frame.height-20))
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        for i in 0...9 {
            if i%2 == 0 {
                self.messages?.append(self.getItem(dic: json1, join: false))
            } else {
                if i == 9 {
                    self.messages?.append(self.getItem(dic: json2, join: true))
                } else {
                    self.messages?.append(self.getItem(dic: json2, join: false))
                }
            }
        }
        self.addSubViews([self.chatView,self.likeView,self.emitter])
        self.likeView.setImage(UIImage("unlike"), for: .normal)
        self.chatView.bounces = false
    }
    
    private func getItem(dic: [String:String],join: Bool) -> VoiceRoomChatEntity {
        let item = VoiceRoomChatEntity()
        item.userName = dic["userName"]
        item.content = dic["content"]
        item.joined = join
        item.attributeContent = item.attributeContent
        item.height = item.height
        return item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VoiceRoomChatView {
    
    @objc func toLike(_ sender: UIButton) {
        self.emitter.setupEmitter()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.messages?[safe: indexPath.row]?.height ?? 60
        return height
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VoiceRoomChatCell") as? VoiceRoomChatCell
        if cell == nil {
            cell = VoiceRoomChatCell(style: .default, reuseIdentifier: "VoiceRoomChatCell")
        }
        cell?.chat = self.messages![safe: indexPath.row]
        cell?.selectionStyle = .none
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y - self.lastOffsetY < 0 {
            self.cellOffset -= cell.frame.height
        } else {
            self.cellOffset += cell.frame.height
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.chatView.indexPathForRow(at: scrollView.contentOffset) ?? IndexPath(row: 0, section: 0)
        let cell = self.chatView.cellForRow(at: indexPath)
        let maxAlphaOffset = cell?.frame.height ?? 40
        let offsetY = scrollView.contentOffset.y
        let alpha = (maxAlphaOffset - (offsetY - self.cellOffset))/maxAlphaOffset
        if offsetY - self.lastOffsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.alpha = alpha
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                cell?.alpha = 1
            }
        }
        self.lastOffsetY = offsetY
        if self.lastOffsetY == 0 {
            self.cellOffset = 0
        }
    }

}
