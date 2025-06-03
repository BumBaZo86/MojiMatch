//
//  LoginView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-20.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showSignup: Bool
    
    @EnvironmentObject var authModel: AuthModel

    var body: some View {
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("MojiMatchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.white)

                VStack(spacing: 16) {
                    Text("Log In")
                        .font(.title)
                        .foregroundColor(.white)

                    TextField("Email", text: $authModel.email)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)

                    SecureField("Password", text: $authModel.password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle("Remember email", isOn: $authModel.rememberEmail)
                        .toggleStyle(SwitchToggleStyle(tint: .white))
                        .foregroundColor(.white)

                    if !authModel.errorMessage.isEmpty {
                        Text(authModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: {
                        authModel.logIn { success in
                            if success {
                                isLoggedIn = true
                            }
                        }
                    }) {
                        if authModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 186/256, green: 221/256, blue: 186/256))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .disabled(authModel.isLoading)
                    .padding(.top)

                    Button(action: {
                        showSignup = true
                    }) {
                        Text("Don't have an account? Sign up")
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
        .onAppear {
            authModel.onAppear()
        }
    }
}
