//
//  VMNorSetTableViewCell.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/7.
//

import UIKit

class VMNorSetTableViewCell: UITableViewCell {

    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width
    private var iconView: UIImageView = UIImageView()
    private var titleLabel: UILabel = UILabel()
    private var indView: UIImageView = UIImageView()
    private var contentLabel: UILabel = UILabel()
    
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
        
        contentLabel.frame = CGRect(x: screenWidth - 150~, y: 17~, width: 100~, height: 30~)
        contentLabel.text = "KTVVVVV"
        contentLabel.textColor = UIColor(red: 60/255.0, green: 66/255.0, blue: 103/255.0, alpha: 1)
        contentLabel.textAlignment = .right
        self.contentView.addSubview(contentLabel)
        
        indView.frame = CGRect(x: screenWidth - 40~, y: 22~, width: 20~, height: 20~)
        indView.image = UIImage(named: "arrow_right_bold")
        self.contentView.addSubview(indView)
        
        self.selectionStyle = .none
    }

}
