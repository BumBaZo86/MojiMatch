//
//  MojiMatchApp.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

import SwiftUI
import FirebaseCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MojiMatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") private var storedLoggedIn: Bool = false
    @State private var showSignup = false

    var body: some Scene {
        WindowGroup {
            if storedLoggedIn {
                ContentView() 
            } else {
                LoginView(isLoggedIn: $storedLoggedIn, showSignup: $showSignup)
            }
        }
    }
}
