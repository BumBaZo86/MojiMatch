//
//  MojiMatchApp.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourAppNameApp: App {
    // Registrera AppDelegate för att få igång FirebaseApp.configure()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Skapa AuthModel som environment object
    @StateObject private var authModel = AuthModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
        }
    }
}
