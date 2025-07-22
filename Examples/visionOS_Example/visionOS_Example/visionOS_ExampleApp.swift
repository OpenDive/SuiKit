//
//  visionOS_ExampleApp.swift
//  visionOS_Example
//
//  Created by Marcus Arnett on 1/24/25.
//

import SwiftUI
import FirebaseCore
import UIKit
import AppAuthCore

class AppDelegate: NSObject, UIApplicationDelegate {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct VisionOSExampleApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
