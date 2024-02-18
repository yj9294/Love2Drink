//
//  Love2drinkApp.swift
//  Love2drink
//
//  Created by Super on 2024/2/6.
//

import SwiftUI
import ComposableArchitecture

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
            return true
        }
    }
}
