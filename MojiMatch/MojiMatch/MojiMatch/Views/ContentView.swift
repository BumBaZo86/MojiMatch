//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showSignup = false

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
            // Kontrollera om användaren fortfarande är inloggad i Firebase
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

            ScoreboardView()
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
