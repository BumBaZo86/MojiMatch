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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showLoginView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                
               
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
              
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
           
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
             
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
            
                Button(action: {
                    signUp()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Sign Up")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading)
                .padding()
                
                
                NavigationLink("", destination: LoginView(), isActive: $showLoginView)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
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
             
                if let user = result?.user {
                    createUserProfile(user: user)
                }
            }
        }
    }
    
    func createUserProfile(user: FirebaseAuth.User) {
      
        let defaultLevel = "Easy"
        let defaultCategories: [String] = ["Animals"]
        let defaultLevels: [String] = ["Easy"]
        let defaultQuestionCounts: [Int] = [5]
        let defaultPoints = 0
        
        let userData: [String: Any] = [
            "email": email,
            "username": username,
            "points": defaultPoints,
            "level": defaultLevel,
            "unlockedCategories": defaultCategories,
            "unlockedLevels": defaultLevels,
            "unlockedQuestionCounts": defaultQuestionCounts
        ]
        
   
        Firestore.firestore().collection("users").document(user.email ?? "").setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to create user profile: \(error.localizedDescription)"
            } else {
                print("User profile created successfully!")
           
                showLoginView = true
            }
        }
    }
}
