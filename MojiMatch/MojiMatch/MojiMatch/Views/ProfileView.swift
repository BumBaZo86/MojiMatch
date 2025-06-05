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

    @StateObject var emojiConverterViewModel = EmojiConverterViewModel()
    
    @State private var user: User? = Auth.auth().currentUser
    @State private var username: String = "Unknown"
    @State private var points: Int = 0
    @State private var stars: Int = 0
    @State private var avatarImage: UIImage?
    @State private var avatarUIImage: Image?
    @State private var errorMessage: String = ""
    @State private var recentGames: [String] = []
    @State private var level: String = "Easy"
    @State private var unlockedCategories: [String] = ["Animals"]
    @State private var unlockedLevels: [String] = ["Easy"]
    @State private var unlockedQuestionCounts: [Int] = [5]
    @State private var isImagePickerPresented = false
    @State private var showSettingsView = false
    @State private var shownRows: [Bool] = []

    @State private var selectedTab = 0

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    private var db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showSettingsView.toggle()
                            }
                        }) {
                            Image("Settings")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(12)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Text("Profile")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 250, height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                        )
                        .fontDesign(.monospaced)
                        .frame(maxWidth: .infinity, alignment: .center)

                    ScrollView {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 190, height: 190)
                                    .background(
                                        Circle()
                                            .stroke(Color(red: 210/255, green: 245/255, blue: 210/255), lineWidth: 7)
                                            .shadow(color: Color(red: 210/255, green: 245/255, blue: 210/255).opacity(0.9), radius: 12, x: 0, y: 0)
                                    )

                                if let avatarUIImage = avatarUIImage {
                                    avatarUIImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 180, height: 180)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 180, height: 180)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                }
                            }

                            Text("Username: \(username)")
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Group {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("💰: \(points)")
                                    Text("⭐: \(stars)")
                                    Text("Categories: \(unlockedCategories.map { emojiConverterViewModel.textToEmoji(for: $0) }.joined(separator: " "))")
                                    Text("Difficulties: \(unlockedLevels.map { emojiConverterViewModel.textToEmoji(for: $0) }.joined(separator: " "))")
                                    Text("Question Counts: \(unlockedQuestionCounts.map { emojiConverterViewModel.textToEmoji(for: String($0)) }.joined(separator: " "))")
                                }
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            }
                            .customGroupStyle()

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
                .tag(0)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Games Top 5")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.top, 16)

                    ScrollView {
                        VStack(spacing: 20) {
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
                                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5)
                                    )
                                    .offset(x: shownRows.indices.contains(index) && shownRows[index] ? 0 : 400)
                                    .opacity(shownRows.indices.contains(index) && shownRows[index] ? 1 : 0)
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .onChange(of: selectedTab) { newValue in
                if newValue == 1 {
                    loadRecentGames()
                }
            }

            if showSettingsView {
                SettingsView(closeAction: {
                    withAnimation {
                        showSettingsView = false
                    }
                })
                .zIndex(1)
            }
        }
        .onAppear {
            loadUserData()
      
        }
    }

    func loadUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        db.collection("users").document(userEmail).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Failed to load user data: \(error.localizedDescription)"
            } else if let document = document, document.exists {
                self.points = document["points"] as? Int ?? 0
                self.stars = document["stars"] as? Int ?? 0
                self.level = document["level"] as? String ?? "Easy"
                self.unlockedCategories = document["unlockedCategories"] as? [String] ?? ["Animals"]
                self.unlockedLevels = document["unlockedLevels"] as? [String] ?? ["Easy"]
                self.unlockedQuestionCounts = document["unlockedQuestionCounts"] as? [Int] ?? [5]
                self.username = document["username"] as? String ?? "Unknown"
                let avatarImageName = document["avatar"] as? String ?? "avatar1"
                loadAvatarImage(named: avatarImageName)
            }
        }
    }

    func loadAvatarImage(named imageName: String) {
        if let image = UIImage(named: imageName) {
            self.avatarUIImage = Image(uiImage: image)
        } else {
            self.avatarUIImage = Image(systemName: "person.circle.fill")
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
                    let games = snapshot?.documents.compactMap { document in
                        document["gameDetails"] as? String
                    } ?? []
                    self.recentGames = games
                    self.shownRows = Array(repeating: false, count: games.count)

                    for index in games.indices {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                            withAnimation(.easeOut(duration: 0.6)) {
                                self.shownRows[index] = true
                            }
                        }
                    }
                }
            }
    }
}
