//
//  VRSoundEffectsList.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/26.
//

import UIKit
import ZSwiftBaseLib

public class VRSoundEffectsList: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    static var heightMap = Dictionary<String,CGFloat>()
    
    private var datas = VRSoundEffectsCell.items()
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).registerCell(VRSoundEffectsCell.self, forCellReuseIdentifier: "VRSoundEffectsCell")
        for item in self.datas {
            VRSoundEffectsList.heightMap[item.title] = item.detail!.z.sizeWithText(font: .systemFont(ofSize: 13, weight: .regular), size: CGSize(width: ScreenWidth - 80, height: 999)).height
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.datas[indexPath.row]
        return VRSoundEffectsList.heightMap[item.title]! + 20 + 92.5
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VRSoundEffectsCell") as? VRSoundEffectsCell
        if cell == nil {
            cell = VRSoundEffectsCell(style: .default, reuseIdentifier: "VRSoundEffectsCell")
        }
        cell?.item = self.datas[safe: indexPath.row]
        return cell ?? VRSoundEffectsCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for item in self.datas { item.selected = false }
        self.datas[safe:indexPath.row]?.selected = true
        self.reloadData()
    }

}
