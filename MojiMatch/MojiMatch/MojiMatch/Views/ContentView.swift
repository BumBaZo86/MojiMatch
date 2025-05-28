//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.

import SwiftUI
import Firebase
import FirebaseAuth
import UIKit

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showSignup = false

  
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 194/255, green: 225/255, blue: 194/255, alpha: 1)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()

            if isLoggedIn {
                MainTabView()
                    .tint(.green)
            } else {
                if showSignup {
                    SignUpView(isLoggedIn: $isLoggedIn, showSignup: $showSignup)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, showSignup: $showSignup)
                }
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                isLoggedIn = true
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("HomeImage")
                    Text("Home")
                }

            StoreView()
                .tabItem {
                    Image("StoreImage")
                    Text("Store")
                }

            GameSettingsView()
                .tabItem {
                    Image("GameSettings")
                    Text("Play")
                }

            ScoreboardView(firebaseViewModel: FirebaseViewModel())
                .tabItem {
                    Image("ScoreboardImage")
                    Text("Scoreboard")
                }

            ProfileView()
                .tabItem {
                    Image("ProfileImage")
                    Text("Profile")
                }
        }
    }
}
