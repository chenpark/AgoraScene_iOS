//
//  VRRoomListView.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/24.
//

import UIKit
import ZSwiftBaseLib

public final class VRRoomListView: UITableView,UITableViewDelegate,UITableViewDataSource {

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.delegate(self).dataSource(self).tableFooterView(UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 75))).separatorStyle(.none).backgroundColor(.clear).registerCell(VRRoomListCell.self, forCellReuseIdentifier: "VRRoomListCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VRRoomListView {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = (150/335.0)*(ScreenWidth-40)+20;
        return CGFloat(ceilf(Float(height)))
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VRRoomListCell") as? VRRoomListCell
        if cell == nil {
            cell = VRRoomListCell(style: .default, reuseIdentifier: "VRRoomListCell")
        }
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
}
