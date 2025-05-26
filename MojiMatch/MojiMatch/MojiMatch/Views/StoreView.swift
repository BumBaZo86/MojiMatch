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

struct StoreView: View {
    
    @State private var lockedCategories = ["Flags", "Countries", "Food", "Riddles", "Movies"]
    @State private var lockedLevels = ["Medium", "Hard"]
    @State private var lockedQuestionCounts = [10, 15]
    
    @State private var userUnlockedCategories: [String] = []
    @State private var userUnlockedLevels: [String] = []
    @State private var userUnlockedQuestionCounts: [Int] = []
    
    @State private var points: Int = 0
    
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
                    
                    storeSection(title: "Category", items: lockedCategories, unlocked: userUnlockedCategories, field: "unlockedCategories")
                    
                    storeSection(title: "Difficulty", items: lockedLevels, unlocked: userUnlockedLevels, field: "unlockedLevels")
                    
                    storeSection(title: "No of questions", items: lockedQuestionCounts.map { "\($0)" }, unlocked: userUnlockedQuestionCounts.map { "\($0)" }, field: "unlockedQuestionCounts")
                }
                .padding()
            }
            .background(Color(red: 124/255, green: 172/255, blue: 125/255).ignoresSafeArea())
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
                            StoreItemView(name: item, emoji: textToEmoji(for: item)) {
                                if field == "unlockedQuestionCounts" {
                                    if let intItem = Int(item) {
                                        unlockItem(item: intItem, field: field)
                                    }
                                } else {
                                    unlockItem(item: item, field: field)
                                }
                            }
                            .frame(width: 120, height: 120)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 3)
                            )
                            .shadow(radius: 3)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
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
    
    func unlockItem<T: Hashable>(item: T, field: String) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)
        
        userRef.updateData([
            field: FieldValue.arrayUnion([item])
        ]) { error in
            if error == nil {
                loadUserData()
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
    let onBuy: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.title)

            Text(name)
                .font(.subheadline)
                .foregroundColor(.black)

            Button(action: onBuy) {
                Text("Buy")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
        }
        .padding(6)
    }
}


#Preview {
    StoreView()
}

