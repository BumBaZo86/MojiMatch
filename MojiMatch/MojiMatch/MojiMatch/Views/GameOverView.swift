//
//  GameOverView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI

struct GameOverView: View {
    var score: Int
    
    @Binding var showGameView: Bool
    @Binding var category: String
    @Binding var time: Double
    @Binding var noOfQuestions: Int
    
    var body: some View {
        
        ZStack{
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                Text("Game Over")
                    .font(.largeTitle)
                
                Text("Your score: \(score) !!")
                    .font(.title2)
                
                NavigationLink(destination: GameView(category: $category, time: $time, noOfQuestions: $noOfQuestions, showGameView: $showGameView)) {
                    Text("Play Again")
                        .buttonStyleCustom()
                }
                
                Button("Home") {
                    showGameView = false
                }
                .buttonStyleCustom()
                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
