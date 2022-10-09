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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var cellHeight: CGFloat = 0
    
    var soundType: SOUND_TYPE = .chat {
        didSet {
            if soundType == .chat {
                typeLabel.text = LanguageManager.localValue(key: "Social Chat")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving the voice call problem of the Social Chat scene, including noise cancellation and echo suppression of the anchor's voice. It can enable users of different network environments and models to enjoy ultra-low delay and clear and beautiful voice in multi-person chat.")
            } else if soundType == .karaoke {
                typeLabel.text = LanguageManager.localValue(key: "Karaoke")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving all kinds of problems in the Karaoke scene of single-person or multi-person singing, including the balance processing of accompaniment and voice, the beautification of sound melody and voice line, the volume balance and real-time synchronization of multi-person chorus, etc. It can make the scenes of Karaoke more realistic and the singers' songs more beautiful.")
            } else if soundType == .game {
                typeLabel.text = LanguageManager.localValue(key: "Gaming Buddy")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving all kinds of problems in the game scene where the anchor plays with him, including the collaborative reverberation processing of voice and game sound, the melody of sound and the beautification of sound lines. It can make the voice of the accompanying anchor more attractive and ensure the scene feeling of the game voice. ")
            } else if soundType == .anchor {
                typeLabel.text = LanguageManager.localValue(key: "Professional Bodcaster")
                detailLabel.text = LanguageManager.localValue(key: "This sound effect focuses on solving the problems of poor sound quality of mono anchors and compatibility with mainstream external sound cards. The sound network stereo collection and high sound quality technology can greatly improve the sound quality of anchors using sound cards and enhance the attraction of live broadcasting rooms. At present, it has been adapted to mainstream sound cards in the market. ")
            }
            cellHeight = textHeight(text: detailLabel.text!, fontSize: 13, width: self.bounds.size.width - 80~)
        }
    }
    
    private func layoutUI() {
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 16
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor(red: 0, green: 159/255.0, blue: 1, alpha: 1).cgColor
        self.addSubview(bgView)

        typeLabel.text = "Social Chat"
        typeLabel.font = UIFont.systemFont(ofSize: 16)
        typeLabel.textColor = UIColor(red: 0, green: 159/255.0, blue: 1, alpha: 1)
        bgView.addSubview(typeLabel)

        detailLabel.text = "The scene deals with the coordination of your voice and the musical accompaniment through high sound quality and echo cancellation to ensure the best karaoke experience"
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        detailLabel.font = UIFont.systemFont(ofSize: 13)
        detailLabel.lineBreakMode = .byCharWrapping
        bgView.addSubview(detailLabel)

        yallaView.image = UIImage(named: "yalla")
        bgView.addSubview(yallaView)

        soulView.image = UIImage(named: "soul")
        bgView.addSubview(soulView)

        usageLabel.text = "Current Customer Usage"
        usageLabel.font = UIFont.systemFont(ofSize: 11)
        usageLabel.textColor = UIColor(red: 0, green: 159/255.0, blue: 1, alpha: 1)
        bgView.addSubview(usageLabel)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = CGRect(x: 20~, y: 0, width: self.bounds.size.width - 40~, height: self.bounds.size.height - 20)
        typeLabel.frame = CGRect(x: 20~, y: 15~, width: 200~, height: 17~)
        detailLabel.frame = CGRect(x: 20~, y: 40~, width: self.bounds.size.width - 80~, height: cellHeight)
        yallaView.frame = CGRect(x: 20~, y: self.bounds.size.height - 55~, width: 20~, height: 20~)
        soulView.frame = CGRect(x: 50~, y: self.bounds.size.height - 55~, width: 20~, height: 20~)
        usageLabel.frame = CGRect(x: 20~, y: self.bounds.size.height - 74~, width: 200~, height: 12~)
    }
    
    func textHeight(text: String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        return text.boundingRect(with:CGSize(width: width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font:UIFont.systemFont(ofSize: fontSize)], context:nil).size.height+5
        
    }
}
