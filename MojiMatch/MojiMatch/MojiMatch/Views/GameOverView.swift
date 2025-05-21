//
//  GameOverView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI

struct GameOverView: View {
    var score: Int

    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over")
                .font(.largeTitle)

            Text("Din poäng: \(score)")
                .font(.title2)

            NavigationLink(destination: GameSettingsView()) {
                Text("Play Again")
                    .padding()
                    .frame(width: 250, height: 60)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                    )
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .fontDesign(.monospaced)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
