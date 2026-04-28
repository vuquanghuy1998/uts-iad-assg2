//
//  BubblePopApp.swift
//  BubblePop
//
//  Created by Quang Huy Vu on 25/4/2026.
//

import SwiftUI

@main
struct BubblePopApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}

// MARK: - AppDelegate: blocks upside-down portrait on iPhone only.
// iPad allows all orientations (upside-down is unsuitable here, e.g. when
// the front camera is at the bottom).
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        // Portrait + both landscape orientations, but NOT upside-down portrait.
        return [.portrait, .landscapeLeft, .landscapeRight]
    }
}
