//
//  ContentView.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-05-14.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct MyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showSignup = false
    
    var body: some View {
        VStack {
            if isLoggedIn {
                VStack {
                    Text("You're logged in!")
                    Button("Add Item to Firestore") {
                        addItemToFirestore()
                    }
                }
            } else {
                if showSignup {
                    // Signup view
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
    
    func addItemToFirestore() {
        let db = Firestore.firestore()
        db.collection("items").addDocument(data: [
            "name": "New Item",
            "createdAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Item added successfully")
            }
        }
    }
}
