//
//  VMAudioSettingView.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/7.
//

import UIKit
import ZSwiftBaseLib

public enum AUDIO_SETTING_TYPE {
    case effect
    case Noise
    case Spatial
}

class VMAudioSettingView: UIView {
    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width
    private var lineImgView: UIImageView = UIImageView()
    private var titleLabel: UILabel = UILabel()
    private var tableView: UITableView = UITableView()
    
    private let swIdentifier = "switch"
    private let slIdentifier = "slider"
    private let nIdentifier = "normal"
    
    var resBlock: ((AUDIO_SETTING_TYPE) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20.0, height: 20.0))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = path.cgPath
        self.layer.mask = layer
        
        lineImgView.frame = CGRect(x: ScreenWidth / 2.0 - 20~, y: 8~, width: 40~, height: 4~)
        lineImgView.image = UIImage(named: "pop_indicator")
        self.addSubview(lineImgView)
        
        titleLabel.frame = CGRect(x: ScreenWidth / 2.0 - 60~, y: 30~, width: 120~, height: 30~)
        titleLabel.textAlignment = .center
        titleLabel.text = "Audio Settings"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(titleLabel)
        
        tableView.frame = CGRect(x: 0, y: 60~, width: ScreenWidth, height: 360~)
        tableView.registerCell(VMSwitchTableViewCell.self, forCellReuseIdentifier: swIdentifier)
        tableView.registerCell(VMSliderTableViewCell.self, forCellReuseIdentifier: slIdentifier)
        tableView.registerCell(VMNorSetTableViewCell.self, forCellReuseIdentifier: nIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        self.addSubview(tableView)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        };
        
    }

}

extension VMAudioSettingView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54~
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40~
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40~))
            headerView.backgroundColor = UIColor(red: 247/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1)
            let titleLabel: UILabel = UILabel(frame: CGRect(x: 20~, y: 5~, width: 300~, height: 30~))
            titleLabel.text = "Bot Settings"
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 146/255.0, alpha: 1)
            headerView.addSubview(titleLabel)
            return headerView
        } else {
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40~))
            headerView.backgroundColor = UIColor(red: 247/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1)
            let titleLabel: UILabel = UILabel(frame: CGRect(x: 20~, y: 5~, width: 300~, height: 30~))
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 146/255.0, alpha: 1)
            titleLabel.text = "Room Audio Settings"
            headerView.addSubview(titleLabel)
            
            let imgView: UIImageView = UIImageView(frame: CGRect(x: 150~, y: 10~, width: 30~, height: 20~))
            imgView.image = UIImage(named: "common／new")
            headerView.addSubview(imgView)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell: VMSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: swIdentifier) as! VMSwitchTableViewCell
                return cell
            } else if indexPath.row == 1 {
                let cell: VMSliderTableViewCell = tableView.dequeueReusableCell(withIdentifier: slIdentifier) as! VMSliderTableViewCell
                return cell
            }
        } else if indexPath.section == 1 {
            let cell: VMNorSetTableViewCell = tableView.dequeueReusableCell(withIdentifier: nIdentifier) as! VMNorSetTableViewCell
            return  cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            guard let block = resBlock else {return}
            switch indexPath.row{
            case 0:
                block(.effect)
            case 1:
                block(.Noise)
            default:
                block(.Spatial)
            }
        }
    }

}
