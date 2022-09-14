//
//  AppDelegate.swift
//  AgoraScene_iOS
//
//  Created by CP on 2022/9/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let VC = UINavigationController(rootViewController: LauchViewController())
        VC.isNavigationBarHidden = true
        self.window?.rootViewController = VC
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        VoiceRoomIMManager.shared?.userQuitRoom(completion: { error in
            
        })
    }

}

