//
//  VMSoundView.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/10/9.
//

import Foundation
import UIKit

class VMSoundView: UIView {
    private var bgView: UIView = UIView()
    private var screenWidth: CGFloat = UIScreen.main.bounds.size.width - 40~
    private var typeLabel: UILabel = UILabel()
    private var detailLabel: UILabel = UILabel()
    private var usageLabel: UILabel = UILabel()
    private var yallaView: UIImageView = UIImageView()
    private var soulView: UIImageView = UIImageView()
    private var selView: UIImageView = UIImageView()
    private var iconBgView: UIView = UIView()
    private var lineImgView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var cellHeight: CGFloat = 0
    
    var soundEffect: String = LanguageManager.localValue(key: "Social Chat") {
        didSet {
            if soundEffect == LanguageManager.localValue(key: "Social Chat") {
                typeLabel.text = LanguageManager.localValue(key: "Social Chat")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving the voice call problem of the Social Chat scene, including noise cancellation and echo suppression of the anchor's voice. It can enable users of different network environments and models to enjoy ultra-low delay and clear and beautiful voice in multi-person chat.")
            } else if soundEffect == LanguageManager.localValue(key: "Karaoke") {
                typeLabel.text = LanguageManager.localValue(key: "Karaoke")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving all kinds of problems in the Karaoke scene of single-person or multi-person singing, including the balance processing of accompaniment and voice, the beautification of sound melody and voice line, the volume balance and real-time synchronization of multi-person chorus, etc. It can make the scenes of Karaoke more realistic and the singers' songs more beautiful.")
            } else if soundEffect == LanguageManager.localValue(key: "Gaming Buddy") {
                typeLabel.text = LanguageManager.localValue(key: "Gaming Buddy")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving all kinds of problems in the game scene where the anchor plays with him, including the collaborative reverberation processing of voice and game sound, the melody of sound and the beautification of sound lines. It can make the voice of the accompanying anchor more attractive and ensure the scene feeling of the game voice. ")
            } else if soundEffect == LanguageManager.localValue(key: "Professional Bodcaster") {
                typeLabel.text = LanguageManager.localValue(key: "Professional Bodcaster")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving the problems of poor sound quality of mono anchors and compatibility with mainstream external sound cards. The sound network stereo collection and high sound quality technology can greatly improve the sound quality of anchors using sound cards and enhance the attraction of live broadcasting rooms. At present, it has been adapted to mainstream sound cards in the market. ")
            }
            cellHeight = textHeight(text: detailLabel.text!, fontSize: 13, width: self.bounds.size.width - 40~)
        }
    }
    
    private func layoutUI() {
        
        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20.0, height: 20.0))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = path.cgPath
        self.layer.mask = layer
        
        bgView.backgroundColor = .white
        self.addSubview(bgView)

        lineImgView.image = UIImage(named: "pop_indicator")
        bgView.addSubview(lineImgView)

        typeLabel.text = "Social Chat"
        typeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        typeLabel.textColor = UIColor(red: 0.016, green: 0.035, blue: 0.145, alpha: 1)
        typeLabel.textAlignment = .center
        bgView.addSubview(typeLabel)

        detailLabel.text = "The scene deals with the coordination of your voice and the musical accompaniment through high sound quality and echo cancellation to ensure the best karaoke experience"
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor(red: 0.235, green: 0.257, blue: 0.403, alpha: 1)
        detailLabel.font = UIFont.systemFont(ofSize: 13)
        detailLabel.lineBreakMode = .byCharWrapping
        bgView.addSubview(detailLabel)
        
        iconBgView.backgroundColor = UIColor(red: 241/255.0, green: 243/255.0, blue: 248/255.0, alpha: 1)
        iconBgView.layer.cornerRadius = 10
        iconBgView.layer.masksToBounds = true
        bgView.addSubview(iconBgView)

        yallaView.image = UIImage(named: "yalla")
        bgView.addSubview(yallaView)

        soulView.image = UIImage(named: "soul")
        bgView.addSubview(soulView)

        usageLabel.text = "The following customers are using it: "
        usageLabel.font = UIFont.systemFont(ofSize: 12)
        usageLabel.textColor = UIColor(red: 0.593, green: 0.612, blue: 0.732, alpha: 1)
        bgView.addSubview(usageLabel)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = CGRect(x: 0~, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        lineImgView.frame = CGRect(x: self.bounds.size.width / 2.0 - 20~, y: 8, width: 40~, height: 4)
        typeLabel.frame = CGRect(x: 20~, y: 32, width: self.bounds.size.width - 40~, height: 18)
        detailLabel.frame = CGRect(x: 20~, y: 60, width: self.bounds.size.width - 40~, height: cellHeight)
        iconBgView.frame = CGRect(x: 20~, y: self.bounds.size.height - 94, width: self.bounds.size.width - 40~, height: 60)
        yallaView.frame = CGRect(x: 30~, y: self.bounds.size.height - 62, width: 20~, height: 20)
        soulView.frame = CGRect(x: 60~, y: self.bounds.size.height - 62, width: 20~, height: 20)
        usageLabel.frame = CGRect(x: 30~, y: self.bounds.size.height - 84, width: 300~, height: 12)
    }
    
    func textHeight(text: String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        return text.boundingRect(with:CGSize(width: width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font:UIFont.systemFont(ofSize: fontSize)], context:nil).size.height+5
        
    }
}
