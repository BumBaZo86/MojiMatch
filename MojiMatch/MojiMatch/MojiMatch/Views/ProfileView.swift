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

    private var db = Firestore.firestore()

    var body: some View {
        VStack {
            Text("Email: \(user?.email ?? "No Email")")
                .font(.headline)
                .padding()

           
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
                isImagePickerPresented.toggle()
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $avatarImage, isImagePickerPresented: $isImagePickerPresented)
            }

            Text("Points: \(points)")

            Text("Level: \(level)")
                .padding(.top)

            Text("Unlocked Categories: \(unlockedCategories.joined(separator: ", "))")
                .padding(.top)

            Text("Unlocked Levels: \(unlockedLevels.joined(separator: ", "))")
                .padding(.top)

            Text("Unlocked Question Counts: \(unlockedQuestionCounts.map { String($0) }.joined(separator: ", "))")
                .padding(.top)

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

            Button("Continue") {
                print("Continue button pressed!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top)
        }
        .onAppear {
            loadUserData()
            loadRecentGames()
            loadAvatarImage()
        }
        .padding()
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
}
