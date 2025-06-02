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
    @EnvironmentObject var appSettings: AppSettings
    
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
            Color(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        appSettings.isSettingsMode.toggle()
                        print("Settings tapped, isSettingsMode = \(appSettings.isSettingsMode)")
                    }) {
                        Image("Settings")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(12)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            isLoggedIn = false
                            print("User logged out successfully.")
                        } catch {
                            errorMessage = "Failed logging out: \(error.localizedDescription)"
                        }
                    }) {
                        Text("Log out")
                            .foregroundColor(.black)
                            .font(.system(.body, design: .monospaced))
                    
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Username: \(user?.email ?? "No Email")")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
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
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(selectedImage: $avatarImage, isImagePickerPresented: $isImagePickerPresented)
                        }
                        
                        Group {
                            VStack(spacing: 8) {
                                Text("Points: \(points)")
                                Text("Level: \(level)")
                                Text("Unlocked Categories: \(unlockedCategories.joined(separator: ", "))")
                                Text("Unlocked Levels: \(unlockedLevels.joined(separator: ", "))")
                                Text("Unlocked Question Counts: \(unlockedQuestionCounts.map { String($0) }.joined(separator: ", "))")
                            }
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        }
                        .customGroupStyle()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Games Top 5")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                            
                            ForEach(Array(recentGames.enumerated()), id: \.offset) { index, game in
                                Text(game)
                                    .padding(8)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(.black)
                                    .frame(width: 350)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5))
                            }
                        }
                        .padding(.top)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
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
            .order(by: "timestamp", descending: true)
            .limit(to: 5)
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
}
