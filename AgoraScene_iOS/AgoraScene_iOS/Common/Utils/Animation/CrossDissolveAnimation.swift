//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation

public class CrossDissolveAnimation: PresentationAnimation {
    
    public override func beforeAnimation(animationContext: AnimationContext) {
        super.beforeAnimation(animationContext: animationContext)
        animationContext.animatingView?.alpha = animationContext.isPresenting ? 0.0 : 1.0
    }
    
    public override func performAnimation(animationContext: AnimationContext) {
        super.performAnimation(animationContext: animationContext)
        animationContext.animatingView?.alpha = animationContext.isPresenting ? 1.0 : 0.0
    }
    
    public override func afterAnimation(animationContext: AnimationContext) {
        super.afterAnimation(animationContext: animationContext)
        animationContext.animatingView?.alpha = 1.0
    }

}
