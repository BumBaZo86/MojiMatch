//
//  ViewModel.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-28.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = "" 
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var rememberEmail: Bool = false

    @AppStorage("isLoggedIn") private var storedLoggedIn: Bool = false
    @AppStorage("rememberedEmail") private var rememberedEmail: String = ""

    func onAppear() {
        email = rememberedEmail
        rememberEmail = !rememberedEmail.isEmpty
    }

    func logIn(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in both fields."
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    if self.rememberEmail {
                        self.rememberedEmail = self.email
                    } else {
                        self.rememberedEmail = ""
                    }
                    self.storedLoggedIn = true
                    completion(true)
                }
            }
        }
    }

    func signUp(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        isLoading = true
        errorMessage = ""

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else if let user = result?.user {
                    self.createUserProfile(user: user) { success in
                        if success {
                            self.storedLoggedIn = true
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
            }
        }
    }

    private func createUserProfile(user: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "username": username,
            "points": 0,
            "level": 1,
            "unlockedCategories": [],
            "unlockedLevels": [],
            "unlockedQuestionCounts": []
        ]

        Firestore.firestore().collection("users").document(user.email ?? "").setData(userData) { error in
            if let error = error {
                self.errorMessage = "Failed to create profile: \(error.localizedDescription)"
                completion(false)
            } else {
                print("User profile created successfully!")
                completion(true)
            }
        }
    }
}
