//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation

extension Notification {
    
    /// 键盘frame
    public var keyboardEndFrame: CGRect? {
        return (userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// 键盘动画时间
    public var keyboardAnimationDuration: TimeInterval? {
        return (userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
    
}
