//
//  StoreView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI

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
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Store")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                ScrollView {
                    Section(header: Text("Categories").font(.headline)) {
                        ForEach(lockedCategories, id: \.self) { category in
                            if !userUnlockedCategories.contains(category) {
                                StoreItemView(name: category, emoji: textToEmoji(for: category)) {
                                    unlockItem(item: category, field: "unlockedCategories")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Difficulties").font(.headline)) {
                        ForEach(lockedLevels, id: \.self) { level in
                            if !userUnlockedLevels.contains(level) {
                                StoreItemView(name: level, emoji: textToEmoji(for: level)) {
                                    unlockItem(item: level, field: "unlockedLevels")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Question Counts").font(.headline)) {
                        ForEach(lockedQuestionCounts, id: \.self) { count in
                            if !userUnlockedQuestionCounts.contains(count) {
                                StoreItemView(name: "\(count)", emoji: textToEmoji(for: "\(count)")) {
                                    unlockItem(item: count, field: "unlockedQuestionCounts")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    func loadUserData() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userEmail).getDocument { document, error in
            if let document = document, document.exists {
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
            if let error = error {
                print("Error unlocking \(item): \(error.localizedDescription)")
            } else {
                print("\(item) unlocked successfully.")
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
        case "Medium": return "🐵"
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
        HStack {
            Text(emoji)
                .font(.largeTitle)
            Text(name)
                .font(.headline)
            Spacer()
            Button(action: onBuy) {
                Text("Buy")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    StoreView()
}
