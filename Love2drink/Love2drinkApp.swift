//
//  Love2drinkApp.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import SwiftUI
import ComposableArchitecture
import FBSDKCoreKit
import GADUtil

@main
struct Love2drinkApp: App {
    @UIApplicationDelegateAdaptor(Appdelegate.self) var appdelegate
    var body: some Scene {
        WindowGroup {
            AppContentView(store: Store(initialState: AppContent.State(), reducer: {
                AppContent()
            }))
        }
    }
    
    class Appdelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            NotificationHelper.shared.register()
            ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )
            GADUtil.share.requestConfig()
            return true
        }
        
        func application(
                _ app: UIApplication,
                open url: URL,
                options: [UIApplication.OpenURLOptionsKey : Any] = [:]
            ) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }
    }
}
