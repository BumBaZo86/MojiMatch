//
//  ProfileView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State private var user: User? = Auth.auth().currentUser
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var recentGames: [String] = []
    @State private var errorMessage: String = ""
    
    @State private var showChangeUsername = false
    @State private var showChangePassword = false
    @State private var showAvatarPicker = false
    
    @State private var avatarImage: UIImage?
    @State private var avatarUIImage: Image?
    
    @State private var points: Int = 0
    @State private var isImagePickerPresented = false
    private var db = Firestore.firestore()

    var body: some View {
        VStack {
           
            Text("Email: \(user?.email ?? "No Email")")
                .font(.headline)
            
            if showChangeUsername {
                VStack {
                    TextField("Enter new username", text: $newUsername)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Update Username") {
                        updateUsername()
                    }
                    .padding()
                }
            } else {
                Text("Username: \(user?.displayName ?? "No Username")")
                    .padding()
                Button("Change Username") {
                    showChangeUsername.toggle()
                }
                .padding()
            }
            
            if showChangePassword {
                VStack {
                    SecureField("Enter new password", text: $newPassword)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Update Password") {
                        updatePassword()
                    }
                    .padding()
                }
            } else {
                Button("Change Password") {
                    showChangePassword.toggle()
                }
                .padding()
            }

      
            if let avatarUIImage = avatarUIImage {
                avatarUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
             
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Button("Change Avatar") {
                isImagePickerPresented.toggle() // Visa ImagePicker
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $avatarImage, isImagePickerPresented: $isImagePickerPresented)
            }

         
            Text("Points: \(points)")

        
            Text("Recent Games")
                .font(.headline)
                .padding(.top)
            
            List(recentGames, id: \.self) { game in
                Text(game)
            }

      
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadRecentGames()
            loadAvatarImage()
            loadUserData()          }
        .padding()
    }
    
    func updateUsername() {
        guard let user = Auth.auth().currentUser else { return }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newUsername
        changeRequest.commitChanges { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "Username updated successfully!"
            }
        }
    }
    
  
    func updatePassword() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "Password updated successfully!"
            }
        }
    }

    func loadRecentGames() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        db.collection("users").document(userEmail).collection("recentGames")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to load recent games: \(error.localizedDescription)"
                } else {
                    self.recentGames = snapshot?.documents.compactMap { document in
                        document["gameDetails"] as? String
                    } ?? []
                }
            }
    }
    

    func loadAvatarImage() {
        guard let user = Auth.auth().currentUser else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                self.errorMessage = "Failed to load avatar image: \(error.localizedDescription)"
            } else if let data = data {
                if let image = UIImage(data: data) {
                    self.avatarImage = image
                    self.avatarUIImage = Image(uiImage: image) // Konvertera till Image
                }
            }
        }
    }
    
 
    func updateAvatarImage() {
        guard let avatarImage = avatarImage else { return }
        guard let user = Auth.auth().currentUser else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        if let imageData = avatarImage.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.errorMessage = "Failed to upload avatar image: \(error.localizedDescription)"
                } else {
                    self.errorMessage = "Avatar image updated successfully!"
                }
            }
        }
    }

    
    func loadUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        db.collection("users").document(userEmail).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Failed to load user data: \(error.localizedDescription)"
            } else if let document = document, document.exists {
                self.points = document["points"] as? Int ?? 0
            }
        }
    }

    func updatePoints(newPoints: Int) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        db.collection("users").document(userEmail).updateData([
            "points": newPoints
        ]) { error in
            if let error = error {
                self.errorMessage = "Failed to update points: \(error.localizedDescription)"
            } else {
                self.errorMessage = "Points updated successfully!"
                self.points = newPoints
            }
        }
    }
}
