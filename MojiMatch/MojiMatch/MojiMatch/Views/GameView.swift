//
//  GameView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct GameView: View {
    
    @ObservedObject var firebaseViewModel = FirebaseViewModel()
    
    @Binding var category : String
    @Binding var time : Int
    @Binding var noOfQuestions : Int
    
    @State var questionCount = 0
    @State var score = 0
    @State private var isGameOver = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 113/256, green: 162/256, blue: 114/256)
                    .ignoresSafeArea()
               
                VStack {
                    HStack {
                        Spacer()
                        Text("Score: \(score)")
                            .padding()
                            .fontDesign(.monospaced)
                    }
                    
                    Spacer()
                    
                    if let question = firebaseViewModel.currentQuestion {
                        if question.question.count < 3 {
                            Text(question.question)
                                .customQuestionText()
                                .font(.system(size: 90))
                        } else if question.question.count < 8 {
                            Text(question.question)
                                .customQuestionText()
                                .font(.system(size: 50))
                        } else {
                            Text(question.question)
                                .customQuestionText()
                                .font(.system(size: 20))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .frame(width: 350, height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                                )
                            
                            VStack(spacing: 25) {
                                Spacer()
                                HStack(spacing: 25) {
                                    Spacer()
                                    optionButton(text: firebaseViewModel.optionA)
                                    optionButton(text: firebaseViewModel.optionB)
                                    Spacer()
                                }
                                HStack(spacing: 25) {
                                    Spacer()
                                    optionButton(text: firebaseViewModel.optionC)
                                    optionButton(text: firebaseViewModel.optionD)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }

                    NavigationLink(destination: GameOverView(score: score), isActive: $isGameOver) {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
            }
        }
    }

    func optionButton(text: String) -> some View {
        Button(action: {
            checkAnswer(text)
        }) {
            Text(text)
        }
        .customAnswerOptions()
        .font(.system(size: text.count < 2 ? 70 : 10))
    }

    func checkAnswer(_ selected: String) {
        if selected == firebaseViewModel.currentQuestion?.answer {
            score += 10
        }

        questionCount += 1

        if questionCount < noOfQuestions {
            firebaseViewModel.fetchQuestionAndAnswer(category: category)
        } else {
            isGameOver = true
        }
    }
}
