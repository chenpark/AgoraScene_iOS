//
//  VMEQSettingView.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/8.
//

import UIKit

class VMEQSettingView: UIView {
    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width
    private var lineImgView: UIImageView = UIImageView()
    private var titleLabel: UILabel = UILabel()
    private var tableView: UITableView = UITableView()
    private var backBtn: UIButton = UIButton()
    
    private let swIdentifier = "switch"
    private let slIdentifier = "slider"
    private let nIdentifier = "normal"
    private let pIdentifier = "sup"
    private let sIdentifier = "set"
    private let soIdentifier = "sound"
    var backBlock: (() -> Void)?
    
    var settingType: AUDIO_SETTING_TYPE = .Spatial {
        didSet {
            if settingType == .Spatial {
                titleLabel.text = "Spatial Setting"
            } else if settingType == .Noise {
                titleLabel.text = "Noise Setting"
            }else if settingType == .effect {
                titleLabel.text = "Effect Setting"
            }
        }
    }
    
    var resBlock: ((AUDIO_SETTING_TYPE) -> Void)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .white
        layoutUI()
    }
    
    private func layoutUI() {
        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20.0, height: 20.0))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = path.cgPath
        self.layer.mask = layer
        
        backBtn.frame = CGRect(x: 10~, y: 30~, width: 20~, height: 30~)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTargetFor(self, action: #selector(back), for: .touchUpInside)
        self.addSubview(backBtn)
        
        lineImgView.frame = CGRect(x: ScreenWidth / 2.0 - 20~, y: 8~, width: 40~, height: 4~)
        lineImgView.image = UIImage(named: "pop_indicator")
        self.addSubview(lineImgView)
        
        titleLabel.frame = CGRect(x: ScreenWidth / 2.0 - 60~, y: 25~, width: 120~, height: 30~)
        titleLabel.textAlignment = .center
        titleLabel.text = "Spatial Audio"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(titleLabel)
        
        tableView.frame = CGRect(x: 0, y: 60~, width: ScreenWidth, height: 390~)
        tableView.registerCell(VMSwitchTableViewCell.self, forCellReuseIdentifier: swIdentifier)
        tableView.registerCell(VMSliderTableViewCell.self, forCellReuseIdentifier: slIdentifier)
        tableView.registerCell(VMNorSetTableViewCell.self, forCellReuseIdentifier: nIdentifier)
        tableView.registerCell(VMANISSUPTableViewCell.self, forCellReuseIdentifier: pIdentifier)
        tableView.registerCell(VMANISSetTableViewCell.self, forCellReuseIdentifier: sIdentifier)
        tableView.registerCell(VMSoundSelTableViewCell.self, forCellReuseIdentifier: soIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        self.addSubview(tableView)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        };
        
    }
    
    @objc private func back() {
        guard let backBlock = backBlock else {
            return
        }
        backBlock()
    }

}

extension VMEQSettingView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch settingType{
        case .effect:
            if indexPath.row == 0 && indexPath.section == 1 {
                return 210~
            } else {
                return 190~
            }
        case .Noise:
            return 54
        case .Spatial:
            return 54
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40~
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if settingType == .effect {
            return section == 0 ? 1 : 2
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40~))
            headerView.backgroundColor = settingType == .effect ? .white : UIColor(red: 247/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1)
            let titleLabel: UILabel = UILabel(frame: CGRect(x: 20~, y: 5~, width: 300~, height: 30~))
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            if settingType == .effect {
                titleLabel.text = "Current Sound Selection"
                titleLabel.textColor = UIColor(red: 60/255.0, green: 66/255.0, blue: 103/255.0, alpha: 1)
            } else {
                titleLabel.text = "Agora Blue Bot"
                titleLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 146/255.0, alpha: 1)
            }
            headerView.addSubview(titleLabel)
            return headerView
        } else {
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40~))
            headerView.backgroundColor = settingType == .effect ? .white : UIColor(red: 247/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1)
            let titleLabel: UILabel = UILabel(frame: CGRect(x: 20~, y: 5~, width: 300~, height: 30~))
            titleLabel.font = UIFont.systemFont(ofSize: 13)
            if settingType == .effect {
                titleLabel.textColor = UIColor(red: 60/255.0, green: 66/255.0, blue: 103/255.0, alpha: 1)
                titleLabel.text = "Other Sound Selection"
            } else {
                titleLabel.textColor = UIColor(red: 108/255.0, green: 113/255.0, blue: 146/255.0, alpha: 1)
                titleLabel.text = "Agora Red Bot"
            }
            headerView.addSubview(titleLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if settingType == .effect {
            tableView.separatorStyle = .none
            let cell: VMSoundSelTableViewCell = tableView.dequeueReusableCell(withIdentifier: soIdentifier) as! VMSoundSelTableViewCell
            cell.isSel = indexPath.section == 0
            if indexPath.section == 0 {
                cell.cellType = .chat
            } else {
                if indexPath.row == 0 {
                    cell.cellType = .karaoke
                } else {
                    cell.cellType = .game
                }
            }
            return cell
        } else {
            if indexPath.row == 1 {
                let cell: VMSliderTableViewCell = tableView.dequeueReusableCell(withIdentifier: slIdentifier) as! VMSliderTableViewCell
                return cell
            } else {
                let cell: VMSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: swIdentifier) as! VMSwitchTableViewCell
                return cell
            }
        }

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

