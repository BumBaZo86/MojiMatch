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

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showLoginView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 113/256, green: 162/256, blue: 114/256)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top)

                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .frame(height: 50)

                        SecureField("Password", text: $password)
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

    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                if let firebaseUser = result?.user {
                    createUserProfile(user: firebaseUser)
                }
            }
        }
    }

    func createUserProfile(user: FirebaseAuth.User) {
        let mojiMatchUser = MojiMatchUser(from: user)

        let userData: [String: Any] = [
            "email": mojiMatchUser.email,
            "username": mojiMatchUser.username,
            "points": mojiMatchUser.points,
            "level": mojiMatchUser.level,
            "unlockedCategories": mojiMatchUser.unlockedCategories,
            "unlockedLevels": mojiMatchUser.unlockedLevels,
            "unlockedQuestionCounts": mojiMatchUser.unlockedQuestionCounts
        ]

        Firestore.firestore().collection("users").document(user.email ?? "").setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to create user profile: \(error.localizedDescription)"
            } else {
                print("User profile created successfully!")
           
                isLoggedIn = true
            }
        }
    }
}
