//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.

import SwiftUI
import Firebase
import FirebaseAuth
import UIKit
import AVFoundation

struct ContentView: View {
    @StateObject private var authModel = AuthModel()
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showSignup = false
    @State private var audioPlayer: AVAudioPlayer?  // Ljudspelare
    
    // Funktion för att spela ljud
    func playButtonSound() {
        guard let url = Bundle.main.url(forResource: "buttonsound", withExtension: "mp3") else {
            print("Ljudfilen hittades inte.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()  // Spela upp ljudet
        } catch {
            print("Fel vid uppspelning av ljud: \(error.localizedDescription)")
        }
    }

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
                        .environmentObject(authModel)
                        .onAppear {
                            playButtonSound()  // Spela ljud när signup-vyn visas
                        }
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, showSignup: $showSignup)
                        .environmentObject(authModel)
                        .onAppear {
                            playButtonSound()  // Spela ljud när login-vyn visas
                        }
                }
            }
        }
        .onAppear {
            authModel.onAppear()
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
