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
                    mojiMatchLogo()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("Sign Up")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.top)
                                .fontDesign(.monospaced)
                            
                            TextField("Email", text: $authModel.email)
                                .logInSignUpTextField()
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .onChange(of: authModel.email) { oldValue, newValue in
                                    authModel.email = newValue.lowercased()
                                    
                                }
                            
                            SecureField("Password", text: $authModel.password)
                                .logInSignUpTextField()
                            
                            TextField("Username", text: $username)
                                .logInSignUpTextField()
                            
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
                                        .buttonStyleCustom()
                                }
                            }
                            .disabled(isLoading)
                            .padding(.top)
                            
                            Button(action: {
                                showSignup = false
                            }) {
                                Text("Already have an account? Log in!")
                                    .foregroundColor(.white)
                                    .underline()
                                    .fontDesign(.monospaced)
                                    .font(.system(size: 13))
                                    
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
        
        let randomAvatarNumber = Int.random(in: 1...6)
        let avatarImageName = "avatar\(randomAvatarNumber)"
        
        let userData: [String: Any] = [
            "email": authModel.email,
            "username": username,
            "points": 0,
            "level": "Easy",
            "unlockedCategories": ["Animals"],
            "unlockedLevels": ["Easy"],
            "unlockedQuestionCounts": [5],
            "avatar": avatarImageName
        ]
        
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
