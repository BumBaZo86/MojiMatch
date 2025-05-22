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

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var rememberEmail: Bool = false

    @AppStorage("isLoggedIn") private var storedLoggedIn: Bool = false
    @AppStorage("rememberedEmail") private var rememberedEmail: String = ""

    var body: some View {
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256) // Bakgrundsfärg (oförändrad)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // Logotyp (SF Symbol som placeholder)
                Image("MojiMatchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.white)
                   // .padding(.top, 40)

                

                VStack(spacing: 16) {
                    Text("Log In")
                        .font(.title)
                        .foregroundColor(.white)

                    TextField("Email", text: $email)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle("Remember email", isOn: $rememberEmail)
                        .toggleStyle(SwitchToggleStyle(tint: .white))
                        .foregroundColor(.white)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: {
                        logIn()
                    }) {
                        if isLoading {
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
                                .scaleEffect(isLoading ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isLoading)
                        }
                    }
                    .disabled(isLoading)
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
            email = rememberedEmail
            rememberEmail = !rememberedEmail.isEmpty
        }
    }

    func logIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both fields."
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                if rememberEmail {
                    rememberedEmail = email
                } else {
                    rememberedEmail = ""
                }
                storedLoggedIn = true
                isLoggedIn = true
                print("Logged in successfully!")
            }
        }
    }
}
