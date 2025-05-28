//
//  GameSettingsView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct GameSettingsView: View {
    
    @State var showGameView = false
    
    // Valda inställningar (med standardvärden)
    @State var category = "Animals"
    @State var time = 10.0
    @State var difficulty = "Easy"
    @State var numberOfQuestions = "5"
    @State var noOfQuestions = 5
    @State var maxPoints = 10
    
    // Tillgängliga val, kombinerat standard + köpta
    @State private var unlockedCategories: [String] = ["Animals"]
    @State private var unlockedLevels: [String] = ["Easy"]
    @State private var unlockedQuestionCounts: [Int] = [5]
    
    let columns = Array(repeating: GridItem(.fixed(80), spacing: 10), count: 4)
    
    var body: some View {
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack {
            
                HStack {
                    Text("Category")
                        .fontDesign(.monospaced)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    ForEach(unlockedCategories, id: \.self) { cat in
                        VStack {
                            Text(textToEmoji(for: cat))
                                .font(.largeTitle)
                            Text(cat)
                                .font(.system(size: 8))
                        }
                        .customGameSettings(isSelected: category == cat)
                        .onTapGesture {
                            category = cat
                        }
                    }
                }
                .padding()
                
            
                HStack {
                    Text("Difficulty")
                        .fontDesign(.monospaced)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    ForEach(unlockedLevels, id: \.self) { level in
                        VStack {
                            Text(textToEmoji(for: level))
                                .font(.largeTitle)
                            Text(level)
                                .font(.system(size: 8))
                        }
                        .customGameSettings(isSelected: difficulty == level)
                        .onTapGesture {
                            difficulty = level
                          
                            switch level {
                            case "Hard":
                                time = 5.0
                                maxPoints = 30
                            case "Medium":
                                time = 7.0
                                maxPoints = 20
                            default:
                                time = 10.0
                                maxPoints = 10
                            }
                        }
                    }
                }
                .padding()
                
           
                HStack {
                    Text("Number of Questions")
                        .fontDesign(.monospaced)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    ForEach(unlockedQuestionCounts, id: \.self) { q in
                        Text(textToEmoji(for: String(q)))
                            .font(.system(size: 19))
                            .customGameSettings(isSelected: numberOfQuestions == String(q))
                            .onTapGesture {
                                numberOfQuestions = String(q)
                                noOfQuestions = q
                            }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    showGameView = true
                }) {
                    Text("Play")
                        .buttonStyleCustom()
                }
                
                Spacer()
            }
            .fullScreenCover(isPresented: $showGameView) {
                GameView(
                    firebaseViewModel: FirebaseViewModel(),
                    category: $category,
                    time: $time,
                    noOfQuestions: $noOfQuestions,
                    maxPoints: $maxPoints,
                    showGameView: $showGameView
                )
            }
        }
        .onAppear {
            fetchUserCategories()
        }
    }
    

    func fetchUserCategories() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userEmail).getDocument { document, error in
            if let error = error {
                print("Failed to load user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                
                let boughtCategories = data["unlockedCategories"] as? [String] ?? []
                let boughtLevels = data["unlockedLevels"] as? [String] ?? []
                let boughtQuestionCounts = data["unlockedQuestionCounts"] as? [Int] ?? []
                
                let defaultCategories = ["Animals"]
                let defaultLevels = ["Easy"]
                let defaultQuestionCounts = [5]
                
                // Kombinera utan dubbletter och sortera
                let combinedCategories = Array(Set(defaultCategories + boughtCategories)).sorted()
                let combinedLevels = Array(Set(defaultLevels + boughtLevels)).sorted()
                let combinedQuestionCounts = Array(Set(defaultQuestionCounts + boughtQuestionCounts)).sorted()
                
                DispatchQueue.main.async {
                    self.unlockedCategories = combinedCategories
                    self.unlockedLevels = combinedLevels
                    self.unlockedQuestionCounts = combinedQuestionCounts
                    
                    // Säkerställ giltiga val, annars sätt förval
                    if !combinedCategories.contains(self.category) {
                        self.category = combinedCategories.first ?? "Animals"
                    }
                    if !combinedLevels.contains(self.difficulty) {
                        self.difficulty = combinedLevels.first ?? "Easy"
                    }
                    if !combinedQuestionCounts.contains(Int(self.numberOfQuestions) ?? 5) {
                        self.numberOfQuestions = String(combinedQuestionCounts.first ?? 5)
                        self.noOfQuestions = combinedQuestionCounts.first ?? 5
                    }
                }
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

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GameSettingsView()
    }
}

