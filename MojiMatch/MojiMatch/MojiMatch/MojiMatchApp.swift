//
//  MojiMatchApp.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

/*test*/
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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authModel = AuthModel()
    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
                .environmentObject(appSettings) 
        }
    }
}

