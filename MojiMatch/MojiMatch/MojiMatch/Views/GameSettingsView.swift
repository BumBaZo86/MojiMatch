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
    @State var noOfQuestions = 5
    @State private var unlockedCategories: [String] = ["Animals"]
    @State private var unlockedLevels: [String] = ["Easy"]
    @State private var unlockedQuestionCounts: [Int] = [5]
    
    let columns = Array(repeating: GridItem(.fixed(80), spacing: 10), count: 3)
    
    var body: some View {
        
        ZStack{
            
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack {
                
                HStack() {
                    Text("Category")
                    Spacer()
                }
                .padding()
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    
                    ForEach(unlockedCategories, id: \.self) { cat in
                    
                        Text(textToEmoji(for: cat))
                            .customGameSettings(isSelected: category == cat)
                            .font(.largeTitle)
                            .onTapGesture {
                                category = cat
                            }
                    }
                }
                .padding()
                
                HStack{
                    Text("Difficulty")
                    Spacer()
                }
                .padding()
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 15) {
                    
                    ForEach(unlockedLevels, id: \.self) { level in
                    
                        Text(textToEmoji(for: level))
                            .customGameSettings(isSelected: difficulty == level)
                            .font(.largeTitle)
                            .onTapGesture {
                                difficulty = level
                            }
                    }
                }
                .padding()
                
                
                
                Spacer()
                
                Button(action: {
                    showGameView = true }) {
                        Text("Play")
                            .buttonStyleCustom()
                    }
                
                Spacer()
                
                    .fullScreenCover(isPresented: $showGameView){
                        GameView(firebaseViewModel: FirebaseViewModel(), category: $category, time: $time, noOfQuestions: $noOfQuestions, showGameView: $showGameView)
                    }
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
                self.unlockedCategories = document["unlockedCategories"] as? [String] ?? ["Animals"]
                self.unlockedLevels = document["unlockedLevels"] as? [String] ?? ["Easy"]
                self.unlockedQuestionCounts = document["unlockedQuestionCounts"] as? [Int] ?? [5]
            }
        }
    }
    
    
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
            
        default:
            return "?"
        }
    }
}

#Preview {
    GameSettingsView()
}
