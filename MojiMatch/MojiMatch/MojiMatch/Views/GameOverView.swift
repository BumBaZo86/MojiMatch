//
//  GameOverView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI

struct GameSettingView: View {
    var body: some View {
        Text("Game Setting View")
            .font(.largeTitle)
    }
}

struct GameOverView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("GameOverView")
                    .font(.title)
                
                NavigationLink(destination: GameSettingView()) {
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
                .padding(.top)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    GameOverView()
}
