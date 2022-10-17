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
    var volBlock: ((Int) -> Void)?
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
        iconView.frame = CGRect(x: 20, y: 17~, width: 20, height: 20~)
        iconView.image = UIImage(named: "icons／set／jiqi")
        self.contentView.addSubview(iconView)
        
        titleLabel.frame = CGRect(x: 50, y: 17~, width: 200, height: 20~)
        titleLabel.text = "AgoraBlue"
        titleLabel.textColor = UIColor(red: 60/255.0, green: 66/255.0, blue: 103/255.0, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        self.contentView.addSubview(titleLabel)
        
        slider.frame = CGRect(x: screenWidth - 225, y: 17~, width: 160, height: 20~)
        slider.addTarget(self, action: #selector(touchEnd), for: .touchUpInside)
        self.contentView.addSubview(slider)
        
        countLabel.frame = CGRect(x: screenWidth - 50, y: 17~, width: 30, height: 20~)
        countLabel.text = "50"
        countLabel.textColor = .lightGray
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(countLabel)
    }
    
    @objc private func touchEnd(slider: UISlider) {
        guard let volBlock = volBlock else {
            return
        }
        volBlock(Int(slider.value * 100))
        countLabel.text = "\(Int(slider.value * 100))"
    }
}
