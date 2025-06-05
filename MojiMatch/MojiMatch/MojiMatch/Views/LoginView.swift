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

            VStack() {
                mojiMatchLogo()

                VStack(spacing: 15) {
                    Text("Log In")
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

                    Toggle("Remember email", isOn: $authModel.rememberEmail)
                        .toggleStyle(SwitchToggleStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .fontDesign(.monospaced)

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
                                .buttonStyleCustom()
                        }
                    }
                    .disabled(authModel.isLoading)
                    .padding(.top)

                    Button(action: {
                        showSignup = true
                    }) {
                        Text("Don't have an account? Sign up!")
                            .foregroundColor(.white)
                            .underline()
                            .fontDesign(.monospaced)
                            .font(.system(size: 13))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .onAppear {
            authModel.onAppear()
        }
    }
}
