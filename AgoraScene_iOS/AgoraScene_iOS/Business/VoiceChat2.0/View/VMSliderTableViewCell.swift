//
//  VMSliderTableViewCell.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/7.
//

import UIKit

class VMSliderTableViewCell: UITableViewCell {

    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width
    public var iconView: UIImageView = UIImageView()
    public var titleLabel: UILabel = UILabel()
    public var slider: UISlider = UISlider()
    public var countLabel: UILabel = UILabel()
    var volBlock: ((Float) -> Void)?
    public var isNoiseSet: Bool = false {
        didSet {
            iconView.isHidden = isNoiseSet
            titleLabel.frame = CGRect(x: isNoiseSet ? 20~ : 50~, y: 17~, width: 200~, height: 20~)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        iconView.frame = CGRect(x: 20~, y: 17~, width: 20~, height: 20~)
        iconView.image = UIImage(named: "icons／set／jiqi")
        self.contentView.addSubview(iconView)
        
        titleLabel.frame = CGRect(x: 50~, y: 17~, width: 200~, height: 20~)
        titleLabel.text = "AgoraBlue"
        titleLabel.textColor = UIColor(red: 60/255.0, green: 66/255.0, blue: 103/255.0, alpha: 1)
        self.contentView.addSubview(titleLabel)
        
        slider.frame = CGRect(x: screenWidth - 180~, y: 17~, width: 120~, height: 30~)
        slider.addTarget(self, action: #selector(touchEnd), for: .touchUpInside)
        self.contentView.addSubview(slider)
        
        countLabel.frame = CGRect(x: screenWidth - 40~, y: 22~, width: 20~, height: 20~)
        countLabel.text = "50"
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.textColor = .lightGray
        self.contentView.addSubview(countLabel)
    }
    
    @objc private func touchEnd(slider: UISlider) {
        
    }
}
