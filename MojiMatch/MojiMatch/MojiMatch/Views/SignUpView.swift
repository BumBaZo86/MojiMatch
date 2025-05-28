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

    @StateObject private var viewModel = AuthModel()

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

                    ScrollView {
                        VStack(spacing: 15) {
                            Text("Sign Up")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.top)

                            TextField("Email", text: $viewModel.email)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .keyboardType(.emailAddress)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)

                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)

                            TextField("Username", text: $viewModel.username)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .frame(height: 50)

                            if !viewModel.errorMessage.isEmpty {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top)
                            }

                            Spacer()

                            Button(action: {
                                viewModel.signUp { success in
                                    if success {
                                        isLoggedIn = true
                                    }
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .frame(width: 250, height: 60)
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
                                        .shadow(radius: 10, x: 20, y: 10)
                                }
                            }
                            .disabled(viewModel.isLoading)
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
                                    .shadow(radius: 10, x: 20, y: 10)
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
}
