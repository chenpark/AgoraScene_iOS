//
//  AgoraMicVolView.swift
//  VoiceChat4Swift
//
//  Created by CP on 2022/8/29.
//

import UIKit
import SnapKit
class AgoraMicVolView: UIView {

    public enum AgoraMicVolViewState {
        case on, off, forbidden
    }
    
    private var imageView: UIImageView!
    
    private var animaView: UIImageView!
    
    private var progressLayer: CAShapeLayer!
    
    private var micState: AgoraMicVolViewState = .off
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.progressLayer.frame = bounds
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
        self.progressLayer.lineWidth = bounds.width
        self.progressLayer.path = path.cgPath
    }
        
    public func setVolume(_ value: Int) {
        guard micState == .on else {
            return
        }
        let floatValue = min(CGFloat(value), 200.00)
        self.progressLayer.strokeEnd = floatValue / 200.0
    }
    
    public func setState(_ state: AgoraMicVolViewState) {
        guard micState != state else {
            return
        }
        self.micState = state
        switch state {
        case .on:
            self.imageView.image = UIImage(named: "ic_mic_status_on")
            self.animaView.isHidden = false
        case .off:
            self.imageView.image = UIImage(named: "ic_mic_status_off")
            self.animaView.isHidden = true
        case .forbidden:
            self.imageView.image = UIImage(named: "ic_mic_status_forbidden")
            self.animaView.isHidden = true
        }
    }

}

private extension AgoraMicVolView {
    func layoutUI() {
        imageView = UIImageView()
        imageView.image = UIImage(named:"ic_mic_status_off")
        addSubview(imageView)
        
        animaView = UIImageView()
        animaView.image = UIImage(named:"ic_mic_status_volume")
        animaView.isHidden  = true
        addSubview(animaView)
        
        progressLayer = CAShapeLayer()
        progressLayer.lineCap = .square
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        animaView.layer.mask = progressLayer
   
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        animaView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
