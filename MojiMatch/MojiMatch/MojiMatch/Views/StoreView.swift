//
//  StoreView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

struct StoreView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var lockedCategories = ["Flags", "Countries", "Food", "Riddles", "Movies"]
    @State private var lockedLevels = ["Medium", "Hard"]
    @State private var lockedQuestionCounts = [10, 15]

    private let categoryPrices: [String: Int] = ["Flags": 10000, "Countries": 20, "Food": 1000, "Riddles": 15000, "Movies": 3000]
    private let levelPrices: [String: Int] = ["Medium": 500, "Hard": 5000]
    private let questionCountPrices: [Int: Int] = [10: 700, 15: 5000]

    @State private var userUnlockedCategories: [String] = []
    @State private var userUnlockedLevels: [String] = []
    @State private var userUnlockedQuestionCounts: [Int] = []
    @State private var points: Int = 0

    @State private var showPointChange = false
    @State private var pointChangeAmount = 0

    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Store")
                        .font(.title2)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.black)
                        .padding(8)
                        .frame(width: 200)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5)
                        )

                    ZStack(alignment: .topTrailing) {
                        Text("💰 \(points)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(8)
                            .frame(width: 150)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5)
                            )

                        if showPointChange {
                            Text("\(pointChangeAmount)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.trailing, 8)
                                .padding(.top, -4)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .animation(.easeOut(duration: 0.4), value: showPointChange)

                    storeSection(
                        title: "Category",
                        items: lockedCategories.sorted { (categoryPrices[$0] ?? 0) < (categoryPrices[$1] ?? 0) },
                        unlocked: userUnlockedCategories,
                        field: "unlockedCategories"
                    )

                    storeSection(
                        title: "Difficulty",
                        items: lockedLevels.sorted { (levelPrices[$0] ?? 0) < (levelPrices[$1] ?? 0) },
                        unlocked: userUnlockedLevels,
                        field: "unlockedLevels"
                    )

                    storeSection(
                        title: "No of questions",
                        items: lockedQuestionCounts
                            .sorted { (questionCountPrices[$0] ?? 0) < (questionCountPrices[$1] ?? 0) }
                            .map { "\($0)" },
                        unlocked: userUnlockedQuestionCounts.map { "\($0)" },
                        field: "unlockedQuestionCounts"
                    )
                }
                .padding(.top, 50)
                .padding()
            }
            .background(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 124/255, green: 172/255, blue: 125/255))
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .onAppear { loadUserData() }
        }
    }

    func storeSection(title: String, items: [String], unlocked: [String], field: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        if !unlocked.contains(item) {
                            let price: Int = {
                                switch field {
                                case "unlockedCategories": return categoryPrices[item] ?? 0
                                case "unlockedLevels": return levelPrices[item] ?? 0
                                case "unlockedQuestionCounts":
                                    return questionCountPrices[Int(item) ?? 0] ?? 0
                                default: return 0
                                }
                            }()

                            StoreItemView(name: item, emoji: textToEmoji(for: item), price: price) {
                                if points >= price {
                                    if field == "unlockedQuestionCounts" {
                                        if let intItem = Int(item) {
                                            unlockItem(item: intItem, field: field, cost: price)
                                        }
                                    } else {
                                        unlockItem(item: item, field: field, cost: price)
                                    }
                                }
                            }
                            .frame(width: 120, height: 120)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5)
        )
        .shadow(radius: 5)
    }

    func loadUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userEmail).getDocument { document, error in
            if let document = document, document.exists {
                self.points = document["points"] as? Int ?? 0
                self.userUnlockedCategories = document["unlockedCategories"] as? [String] ?? []
                self.userUnlockedLevels = document["unlockedLevels"] as? [String] ?? []
                self.userUnlockedQuestionCounts = document["unlockedQuestionCounts"] as? [Int] ?? []
            }
        }
    }

    func unlockItem<T: Hashable>(item: T, field: String, cost: Int) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)

        userRef.updateData([
            field: FieldValue.arrayUnion([item]),
            "points": FieldValue.increment(Int64(-cost))
        ]) { error in
            if error == nil {
                pointChangeAmount = -cost
                withAnimation(.easeOut(duration: 0.4)) {
                    showPointChange = true
                    playCashSound()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation {
                        showPointChange = false
                    }
                }

                loadUserData()
            }
        }
    }

    func playCashSound() {
        if let soundURL = Bundle.main.url(forResource: "cashier", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Kunde inte spela upp ljudet: \(error.localizedDescription)")
            }
        }
    }

    func textToEmoji(for category: String) -> String {
        switch category {
        case "Animals": return "🦁"
        case "Flags": return "🇬🇶"
        case "Countries": return "🌍"
        case "Food": return "🍝"
        case "Riddles": return "❓"
        case "Movies": return "🎥"
        case "Easy": return "🍼"
        case "Medium": return "😐"
        case "Hard": return "🔥"
        case "5": return "5️⃣"
        case "10": return "🔟"
        case "15": return "1️⃣5️⃣"
        default: return "❔"
        }
    }
}

struct StoreItemView: View {
    let name: String
    let emoji: String
    let price: Int
    let onBuy: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.title)
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Button(action: onBuy) {
                    Text("💰 \(price)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(6)
                }
            }
            .padding(8)

            Text("🔒")
                .font(.largeTitle)
                .padding(.bottom, -6)
                .padding(.trailing, -20)
        }
    }
}
