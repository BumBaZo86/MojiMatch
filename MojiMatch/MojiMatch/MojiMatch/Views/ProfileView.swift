//
//  ProfileView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State private var user: User? = Auth.auth().currentUser
    @State private var points: Int = 0
    @State private var avatarImage: UIImage?
    @State private var avatarUIImage: Image?
    @State private var errorMessage: String = ""
    @State private var recentGames: [String] = []
    @State private var level: String = "Easy"
    @State private var unlockedCategories: [String] = ["Animals"]
    @State private var unlockedLevels: [String] = ["Easy"]
    @State private var unlockedQuestionCounts: [Int] = [5]
    @State private var isImagePickerPresented = false

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    private var db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Email: \(user?.email ?? "No Email")")
                        .font(.headline)
                        .foregroundColor(.white)

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
                            .foregroundColor(.white)
                    }

                    Button("Change Avatar") {
                        isImagePickerPresented.toggle()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $avatarImage, isImagePickerPresented: $isImagePickerPresented)
                    }

                    Group {
                        Text("Points: \(points)")
                        Text("Level: \(level)")
                        Text("Unlocked Categories: \(unlockedCategories.joined(separator: ", "))")
                        Text("Unlocked Levels: \(unlockedLevels.joined(separator: ", "))")
                        Text("Unlocked Question Counts: \(unlockedQuestionCounts.map { String($0) }.joined(separator: ", "))")
                    }
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Games")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(recentGames, id: \.self) { game in
                            Text(game)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            isLoggedIn = false
                            print("User logged out successfully.")
                        } catch {
                            errorMessage = "Misslyckades logga ut: \(error.localizedDescription)"
                        }
                    }) {
                        Text("Logga ut")
                            .padding()
                            .frame(width: 250, height: 60)
                            .foregroundStyle(Color.black)
                            .foregroundStyle(.white)
                            .background(Color.white)
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
                .padding()
            }
        }
        .onAppear {
            loadUserData()
            loadRecentGames()
        }
    }

    func loadUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        db.collection("users").document(userEmail).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Failed to load user data: \(error.localizedDescription)"
            } else if let document = document, document.exists {
                self.points = document["points"] as? Int ?? 0
                self.level = document["level"] as? String ?? "Easy"
                self.unlockedCategories = document["unlockedCategories"] as? [String] ?? ["Animals"]
                self.unlockedLevels = document["unlockedLevels"] as? [String] ?? ["Easy"]
                self.unlockedQuestionCounts = document["unlockedQuestionCounts"] as? [Int] ?? [5]
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

    // Placeholder if you later want to load a stored profile image from Firebase Storage
    /*
    func loadAvatarImage() {
        guard let user = Auth.auth().currentUser else { return }

        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                self.errorMessage = "Failed to load avatar image: \(error.localizedDescription)"
            } else if let data = data {
                if let image = UIImage(data: data) {
                    self.avatarImage = image
                    self.avatarUIImage = Image(uiImage: image)
                }
            }
        }
    }
    */
}
