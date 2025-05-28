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
import FirebaseStorage


struct GameSettingsView: View {
    
    @State var showGameView = false
    @State var category = "Animals"
    @State var time = 10.0
    @State var difficulty = "Easy"
    @State var numberOfQuestions = "5"
    @State var noOfQuestions = 5
    @State var maxPoints = 10
    @State private var unlockedCategories: [String] = ["Animals"]
    @State private var unlockedLevels: [String] = ["Easy"]
    @State private var unlockedQuestionCounts: [Int] = [5]
    
    // Arrange the categories into 4 items in each row. Fixed space from each item to the next.
    let columns = Array(repeating: GridItem(.fixed(80), spacing: 10), count: 4)
    
    var body: some View {
        
        ZStack{
            
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack {
                
                HStack() {
                    Text("Category")
                        .fontDesign(.monospaced)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Arrange the categories in rows.
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    
                    ForEach(unlockedCategories, id: \.self) { cat in
                    
                        VStack{
                            Text(textToEmoji(for: cat))
                                .font(.largeTitle)
                            
                            Text(cat)
                                .font(.system(size: 8))
                        }
                        .customGameSettings(isSelected: category == cat)
                        .onTapGesture {
                            category = cat //selected category gets different background color and is updated to be ready to be sent to game.
                            
                        }
                    }
                }
                .padding()
                
                HStack{
                    Text("Difficulty")
                        .fontDesign(.monospaced)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    
                    ForEach(unlockedLevels, id: \.self) { level in
                        VStack{
                            Text(textToEmoji(for: level))
                                .font(.largeTitle)
                            Text(level)
                                .font(.system(size: 8))
                        }
                        .customGameSettings(isSelected: difficulty == level)
                        .onTapGesture {
                            difficulty = level
                            
                            //maxPoint means how many points each correct answer will be worth.
                            if (level == "Hard"){
                                time = 5.0
                                maxPoints = 30
                            } else if (level == "Medium"){
                                time = 7.0
                                maxPoints = 20
                            } else {
                                time = 10.0
                                maxPoints = 10
                            }
                        }
                    }
                }
                .padding()
                
                
                HStack{
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
                            .customGameSettings(isSelected: numberOfQuestions  == String(q))
                            .onTapGesture {
                                numberOfQuestions = String(q)
                                noOfQuestions = Int(numberOfQuestions) ?? 5
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
                //Sheet that does not contain the tabview. Send all the info to gameview.
                    .fullScreenCover(isPresented: $showGameView){
                        GameView(firebaseViewModel: FirebaseViewModel(), category: $category, time: $time, noOfQuestions: $noOfQuestions, maxPoints: $maxPoints, showGameView: $showGameView)
                    }
            }
        }
        .onAppear {
            fetchUserCategories()
        }
    }
    
    /**
     * Fetches the users unlocked categories/difficulty/noOfQs from firebase.
     */
    
    func fetchUserCategories() {
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()

        db.collection("users").document(userEmail).getDocument { document, error in
            if let error = error {
                print("Failed to load user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                self.unlockedCategories = document["unlockedCategories"] as? [String] ?? ["Animals"]
                self.unlockedLevels = document["unlockedLevels"] as? [String] ?? ["Easy"]
                self.unlockedQuestionCounts = document["unlockedQuestionCounts"] as? [Int] ?? [5]
            }
        }
    }
    
    /**
     * Makes the squares with categories/difficulty/noOfQs to emojis instead of letters.
     */
    func textToEmoji(for category: String) -> String {
        
        switch category {
            
        case "Animals":
            return "🦁"
        case "Flags":
            return "🇬🇶"
        case "Countries":
            return "🌍"
        case "Food":
            return "🍝"
        case "Riddles":
            return "❓"
        case "Movies":
            return "🎥"
        case "Easy":
            return "🍼"
        case "Medium":
            return "🐵"
        case "Hard":
            return "🔥"
        case "5":
            return "5️⃣"
        case "10":
            return "🔟"
        case "15":
            return "1️⃣5️⃣"
            
        default:
            return "?"
        }
    }
}

#Preview {
    GameSettingsView()
}
