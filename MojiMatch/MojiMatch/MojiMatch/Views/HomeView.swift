//
//  HomeView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI

struct HomeView: View {
    @State private var showInfo = false
    @State private var showRules = false
    @State private var navigateToGameSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 113/256, green: 162/256, blue: 114/256)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Image("MojiMatchLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.white)

                    Button(action: {
                        navigateToGameSettings = true
                    }) {
                        Text("Play")
                            .font(.title2)
                            .padding()
                            .frame(width: 200)
                            .background(Color(red: 186/256, green: 221/256, blue: 186/256))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    Button(action: {
                        showRules = true
                    }) {
                        Text("Rules")
                            .font(.title2)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    Button(action: {
                        showInfo = true
                    }) {
                        Text("Info")
                            .font(.title2)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    NavigationLink(destination: GameSettingsView(), isActive: $navigateToGameSettings) {
                        EmptyView()
                    }
                }
                .padding()
            }
            // Rules sheet
            .sheet(isPresented: $showRules) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🧠 Rules")
                        .font(.largeTitle)
                        .bold()
                    Text("""
1. Choose a category and the number of questions.
2. Each question has four answer options – pick the correct one before time runs out.
3. You earn 10 points for every correct answer.
4. The game ends when all questions are answered or the timer reaches zero.

Think fast and aim for a high score!
""")
                    Spacer()
                    Button("Close") {
                        showRules = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 113/256, green: 162/256, blue: 114/256))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }

            // Info sheet
            .sheet(isPresented: $showInfo) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("ℹ️ Info")
                        .font(.largeTitle)
                        .bold()
                    Text("""
MojiMatch is a fast-paced quiz game designed to challenge your memory and reaction time.

Choose your category, race against the clock, and see how high you can score!

The app is built with SwiftUI and uses Firebase to fetch live quiz questions.

👾 Created with passion by [Your Name].
""")
                    Spacer()
                    Button("Close") {
                        showInfo = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 113/256, green: 162/256, blue: 114/256))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}
