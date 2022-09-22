//
//  VMANISSUPTableViewCell.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/7.
//

import UIKit
public enum SUP_CELL_TYPE {
    case normal
    case detail
}

class VMANISSUPTableViewCell: UITableViewCell {

    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width
    public var titleLabel: UILabel = UILabel()
    public var detailLabel: UILabel = UILabel()
    private var noneBtn: UIButton = UIButton()
    private var anisBtn: UIButton = UIButton()
    private var selBtn: UIButton!
    
    public var cellType: SUP_CELL_TYPE = .normal {
        didSet {
            if cellType == .normal {
                detailLabel.isHidden = true
                titleLabel.frame = CGRect(x: 20~, y: 17~, width: 200~, height: 20~)
            } else {
                detailLabel.isHidden = false
                titleLabel.frame = CGRect(x: 20~, y: 10~, width: 200~, height: 20~)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        titleLabel.frame = CGRect(x: 20~, y: 10~, width: 200~, height: 20~)
        titleLabel.text = "TV Sound"
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(titleLabel)
        
        detailLabel.frame = CGRect(x: 20~, y: 30~, width: 150~, height: 30~)
        detailLabel.text = "Ex bird, car,subway sounds"
        detailLabel.font = UIFont.systemFont(ofSize: 11)
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byCharWrapping
        detailLabel.textColor = UIColor(red: 151/255.0, green: 156/255.0, blue: 187/255.0, alpha: 1)
        self.contentView.addSubview(detailLabel)
        detailLabel.isHidden = true
        
        noneBtn.frame = CGRect(x: screenWidth - 70~, y: 12~, width: 50~, height: 30~)
        noneBtn.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1)
        noneBtn.setTitle("Off", for: .normal)
        noneBtn.setTitleColor(UIColor(red: 151/255.0, green: 156/255.0, blue: 187/255.0, alpha: 1), for: .normal)
        noneBtn.font(UIFont.systemFont(ofSize: 11))
        noneBtn.layer.cornerRadius = 3
        noneBtn.layer.masksToBounds = true
        noneBtn.tag = 100
        noneBtn.addTargetFor(self, action: #selector(click), for: .touchUpInside)
        self.addSubview(noneBtn)
        
        anisBtn.frame = CGRect(x: screenWidth - 160~, y: 12~, width: 80~, height: 30~)
        anisBtn.backgroundColor = .white
        anisBtn.setTitle("Middle", for: .normal)
        anisBtn.setTitleColor(UIColor.blue, for: .normal)
        anisBtn.font(UIFont.systemFont(ofSize: 11))
        anisBtn.backgroundColor = .white
        anisBtn.layer.cornerRadius = 3
        anisBtn.layer.masksToBounds = true
        anisBtn.layer.borderColor = UIColor.blue.cgColor
        anisBtn.layer.borderWidth = 1
        anisBtn.tag = 101
        anisBtn.addTargetFor(self, action: #selector(click), for: .touchUpInside)
        self.addSubview(anisBtn)
        
    }
    
    @objc private func click(sender: UIButton) {
        sender.backgroundColor = .white
        sender.layer.borderColor = UIColor.blue.cgColor
        sender.setTitleColor(.blue, for: .normal)
        sender.layer.borderWidth = 1
        
        selBtn.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1)
        selBtn.setTitleColor(UIColor(red: 151/255.0, green: 156/255.0, blue: 187/255.0, alpha: 1), for: .normal)
        selBtn.layer.borderColor = UIColor.clear.cgColor
        selBtn.layer.borderWidth = 0
        selBtn = sender
    }


}
