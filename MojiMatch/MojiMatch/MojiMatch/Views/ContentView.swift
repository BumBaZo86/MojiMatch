//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showSignup = false
    
    var body: some View {
        VStack {
            if isLoggedIn {
        
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                    
                    StoreView()
                        .tabItem{
                            Image(systemName: "cart")
                            Text("Store")
                        }
                    
                    GameSettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Play")
                        }
                    
                    ScoreboardView()
                        .tabItem {
                            Image(systemName: "list.number")
                            Text("Scoreboard")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                }
                .tint(.green)
            } else {
    
                if showSignup {
                    // Registreringsvy
                    VStack {
                        TextField("Email", text: $email)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        SecureField("Password", text: $password)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Sign Up") {
                            signUp()
                        }
                        .padding()
                        
                        Button("Already have an account? Log in") {
                            showSignup.toggle()
                        }
                        
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                } else {
               
                    VStack {
                        TextField("Email", text: $email)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        SecureField("Password", text: $password)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Log In") {
                            logIn()
                        }
                        .padding()
                        
                        Button("Don't have an account? Sign up") {
                            showSignup.toggle()
                        }
                        
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
    }
    

    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
    

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}
