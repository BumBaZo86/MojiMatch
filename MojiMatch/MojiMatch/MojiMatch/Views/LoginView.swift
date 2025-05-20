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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        VStack {
            Text("Log In")
                .font(.largeTitle)
                .padding()

          
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

         
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

          
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

       
            Button(action: {
                logIn()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Log In")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)
            .padding()
            
           
            if isLoggedIn {
                ContentView()
            }
        }
        .padding()
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
                
                isLoggedIn = true
                print("Logged in successfully!")
            }
        }
    }
}
