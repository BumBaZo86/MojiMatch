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
            ZStack {
                Color(red: 124/255, green: 172/255, blue: 125/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
            
                    Text("Store")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.black)
                        .padding()
                        .frame(width: 250, height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                        )
                        .shadow(radius: 10, x: 5, y: 5)
                    
                  
                    Text("Points: \(points)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                        )
                        .shadow(radius: 10, x: 5, y: 5)
                    
          
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Categories")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ForEach(lockedCategories, id: \.self) { category in
                            if !userUnlockedCategories.contains(category) {
                                StoreItemView(name: category, emoji: textToEmoji(for: category)) {
                                    unlockItem(item: category, field: "unlockedCategories")
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                    )
                    .shadow(radius: 10, x: 5, y: 5)
                    .padding(.horizontal)
                    
          
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulties")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ForEach(lockedLevels, id: \.self) { level in
                            if !userUnlockedLevels.contains(level) {
                                StoreItemView(name: level, emoji: textToEmoji(for: level)) {
                                    unlockItem(item: level, field: "unlockedLevels")
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                    )
                    .shadow(radius: 10, x: 5, y: 5)
                    .padding(.horizontal)
                    
              
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question Counts")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ForEach(lockedQuestionCounts, id: \.self) { count in
                            if !userUnlockedQuestionCounts.contains(count) {
                                StoreItemView(name: "\(count)", emoji: textToEmoji(for: "\(count)")) {
                                    unlockItem(item: count, field: "unlockedQuestionCounts")
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                    )
                    .shadow(radius: 10, x: 5, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadUserData()
            }
        }
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
                .foregroundColor(.black)
            Spacer()
            Button(action: onBuy) {
                Text("Buy")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}


#Preview {
    StoreView()
}
