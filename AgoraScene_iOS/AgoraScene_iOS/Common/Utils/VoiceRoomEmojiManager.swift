//
//  VoiceRoomEmojiManager.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/9/5.
//

import UIKit

fileprivate let manager = VoiceRoomEmojiManager()

@objc open class VoiceRoomEmojiManager: NSObject {
    
    @objc static let shared = manager
    
    @objc var emojiMap: Dictionary<String,UIImage> = ["0x1F600":UIImage("0x1F600")!,"0x1F604":UIImage("0x1F604")!,"0x1F609":UIImage("0x1F609")!,"0x1F62E":UIImage("0x1F62E")!,"0x1F92A":UIImage("0x1F92A")!,"0x1F60E":UIImage("0x1F60E")!,"0x1F971":UIImage("0x1F971")!,"0x1F974":UIImage("0x1F974")!,"0x263A":UIImage("0x263A")!,"0x1F641":UIImage("0x1F641")!,"0x1F62D":UIImage("0x1F62D")!,"0x1F610":UIImage("0x1F610")!,"0x1F607":UIImage("0x1F607")!,"0x1F62C":UIImage("0x1F62C")!,"0x1F913":UIImage("0x1F913")!,"0x1F633":UIImage("0x1F633")!,"0x1F973":UIImage("0x1F973")!,"0x1F620":UIImage("0x1F620")!,"0x1F644":UIImage("0x1F644")!,"0x1F910":UIImage("0x1F910")!,"0x1F97A":UIImage("0x1F97A")!,"0x1F928":UIImage("0x1F928")!,"0x1F62B":UIImage("0x1F62B")!,"0x1F637":UIImage("0x1F637")!,"0x1F912":UIImage("0x1F912")!,"0x1F631":UIImage("0x1F631")!,"0x1F618":UIImage("0x1F618")!,"0x1F60D":UIImage("0x1F60D")!,"0x1F922":UIImage("0x1F922")!,"0x1F47F":UIImage("0x1F47F")!,"0x1F92C":UIImage("0x1F92C")!,"0x1F621":UIImage("0x1F621")!,"0x1F44D":UIImage("0x1F44D")!,"0x1F44E":UIImage("0x1F44E")!,"0x1F44F":UIImage("0x1F44F")!,"0x1F64C":UIImage("0x1F64C")!,"0x1F91D":UIImage("0x1F91D")!,"0x1F64F":UIImage("0x1F64F")!,"0x2764":UIImage("0x2764")!,"0x1F494":UIImage("0x1F494")!,"0x1F495":UIImage("0x1F495")!,"0x1F4A9":UIImage("0x1F4A9")!,"0x1F48B":UIImage("0x1F48B")!,"0x2600":UIImage("0x2600")!,"0x1F31C":UIImage("0x1F31C")!,"0x1F308":UIImage("0x1F308")!,"0x2B50":UIImage("0x2B50")!,"0x1F31F":UIImage("0x1F31F")!,"0x1F389":UIImage("0x1F389")!,"0x1F490":UIImage("0x1F490")!]
    
    @objc var emojis: [String] = ["0x1F600","0x1F604","0x1F609","0x1F62E","0x1F92A","0x1F60E","0x1F971","0x1F974","0x263A","0x1F641","0x1F62D","0x1F610","0x1F607","0x1F62C","0x1F913","0x1F633","0x1F973","0x1F620","0x1F644","0x1F910","0x1F97A","0x1F928","0x1F62B","0x1F637","0x1F912","0x1F631","0x1F618","0x1F60D","0x1F922","0x1F47F","0x1F92C","0x1F621","0x1F44D","0x1F44E","0x1F44F","0x1F64C","0x1F91D","0x1F64F","0x2764","0x1F494","0x1F495","0x1F4A9","0x1F48B","0x2600","0x1F31C","0x1F308","0x2B50","0x1F31F","0x1F389","0x1F490"]
    
    @objc func changeEmojisMap(map: Dictionary<String,UIImage>,emojis: [String]) {
        self.emojiMap = map
        self.emojis = emojis
    }
    
    @objc func convertEmoji(input: NSMutableAttributedString,ranges: [NSRange],symbol: String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(attributedString: input)
        for range in ranges.reversed() {
            if range.location != NSNotFound,range.length != NSNotFound {
                let value = self.emojiMap[symbol]
                let attachment = NSTextAttachment()
                attachment.image = value
                attachment.bounds = CGRect(x: 0, y: -2.5, width: 18, height: 18)
                text.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
            }
        }
        return text
    }
}
