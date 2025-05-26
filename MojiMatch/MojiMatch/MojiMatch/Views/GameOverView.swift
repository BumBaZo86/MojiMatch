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

    var body: some View {
        ZStack {
            Color(red: 113/255, green: 162/255, blue: 114/255)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("Game Over!")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Text("Your score: \(score) !!")
                    .font(.title2)
                    .foregroundColor(.white)

                NavigationLink(destination: GameView(
                    category: $category,
                    time: $time,
                    noOfQuestions: $noOfQuestions,
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
}
