//
//  GameOverView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct GameOverView: View {
    var score: Int

    @Binding var showGameView: Bool
    @Binding var category: String
    @Binding var time: Double
    @Binding var noOfQuestions: Int
    @Binding var maxPoints : Int
    @Binding var starOne : Bool
    @Binding var starTwo : Bool
    @Binding var starThree : Bool
    
    @State var showStarOne : Bool = false
    @State var showStarTwo : Bool = false
    @State var showStarThree : Bool = false

    var body: some View {
        ZStack {
            Color(red: 113/255, green: 162/255, blue: 114/255)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("Well done!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                HStack {
                    Spacer()
                    if showStarOne {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(Color.yellow)
                            .transition(.scale)
                    }
                    
                    if showStarTwo {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.yellow)
                            .frame(width: 65, height: 65)
                            .transition(.scale)
                        
                    }
                    
                    if showStarThree {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.yellow)
                            .frame(width: 65, height: 65)
                            .transition(.scale)
                    }
                    Spacer()
                }
                .padding()

                Text("Your score: \(score) !!")
                    .font(.title2)
                    .foregroundColor(.white)

                NavigationLink(destination: GameView(
                    category: $category,
                    time: $time,
                    noOfQuestions: $noOfQuestions,
                    maxPoints: $maxPoints,
                    showGameView: $showGameView
                    
                    
                )) {
                    Text("Play Again")
                        .buttonStyleCustom()
                }

                Button("Close game") {
                    showGameView = false
                }
                .buttonStyleCustom()

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                saveGameData()
            }
        }
        .onAppear {
            starAnimation()
        }
    }

    func saveGameData() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No logged in user.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let previousPoints = document["points"] as? Int ?? 0
                userRef.updateData(["points": previousPoints + score]) { err in
                    if let err = err {
                        print("Error updating points: \(err.localizedDescription)")
                    }
                }
            } else {
                userRef.setData(["points": score], merge: true) { err in
                    if let err = err {
                        print("Error setting points: \(err.localizedDescription)")
                    }
                }
            }
        }

        let gameDetails = "Category: \(category), Time: \(Int(time)) sek, Questions: \(noOfQuestions), Points: \(score)"
        let recentGame = ["gameDetails": gameDetails, "timestamp": Timestamp()] as [String : Any]
        userRef.collection("recentGames").addDocument(data: recentGame) { err in
            if let err = err {
                print("Error saving recent game: \(err.localizedDescription)")
            }
        }
    }
    
    func starAnimation() {
        
        
        if starOne {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showStarOne = true
                }
            }
        }
        
        if starTwo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showStarTwo = true
                }
            }
        }
        
        if starThree {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showStarThree = true
                }
            }
        }
    }
}
