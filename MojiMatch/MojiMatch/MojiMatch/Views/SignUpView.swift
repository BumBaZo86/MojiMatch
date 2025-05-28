//
//  SignUpView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showSignup: Bool
    
    @EnvironmentObject var authModel: AuthModel
    
    @State private var username: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 113/256, green: 162/256, blue: 114/256)
                    .ignoresSafeArea()
                
                VStack {
                    Image("MojiMatchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.white)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("Sign Up")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.top)
                            
                            TextField("Email", text: $authModel.email)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .keyboardType(.emailAddress)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)
                            
                            SecureField("Password", text: $authModel.password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)
                            
                            TextField("Username", text: $username)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                signUp()
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 250, height: 60)
                                        .foregroundColor(.black)
                                } else {
                                    Text("Sign Up")
                                        .padding()
                                        .frame(width: 250, height: 60)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                                        )
                                        .shadow(radius: 10.0, x: 20, y: 10)
                                        .fontDesign(.monospaced)
                                }
                            }
                            .disabled(isLoading)
                            .padding(.top)
                            
                            Button(action: {
                                showSignup = false
                            }) {
                                Text("Login")
                                    .padding()
                                    .frame(width: 250, height: 60)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                                    )
                                    .shadow(radius: 10.0, x: 20, y: 10)
                                    .fontDesign(.monospaced)
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
        }
    }
    
    func signUp() {
        guard !authModel.email.isEmpty, !authModel.password.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: authModel.email, password: authModel.password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let firebaseUser = result?.user {
                    createUserProfile(user: firebaseUser)
                }
            }
        }
    }
    
    func createUserProfile(user: FirebaseAuth.User) {

        let userData: [String: Any] = [
            "email": authModel.email,
            "username": username,
            "points": 0,
            "level": "Easy",
            "unlockedCategories": ["Animals"],
            "unlockedLevels": ["Easy"],
            "unlockedQuestionCounts": [5]
        ]
        
        // Använd email som dokument-ID för att matcha hur du hämtar i GameSettingsView
        Firestore.firestore().collection("users").document(authModel.email).setData(userData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                } else {
                    print("User profile created successfully!")
                    isLoggedIn = true
                }
            }
        }
    }
}
