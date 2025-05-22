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
    
    @Binding var category: String
    @Binding var time: Double
    @Binding var noOfQuestions: Int
    @Binding var showGameView: Bool
    
    @State var questionCount = 0
    @State var score = 0
    @State private var isGameOver = false
    @State var timeRemaining = 10.0
    @State var timer: Timer?
    
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
                            .padding(.top, 50)
                            .fontDesign(.monospaced)
                    }
                    
                    if let question = firebaseViewModel.currentQuestion {
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: fontSize(for: question.question)))
                        
                        Spacer(minLength: 80)
                        
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
                        
                        HStack {
                            Spacer()
                            Text(String(format: "%02d:%02d", Int(ceil(timeRemaining)) / 60, Int(ceil(timeRemaining)) % 60))
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        
                        ProgressView(value: max(0, timeRemaining), total: time)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.black)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 90)
                    
                    NavigationLink(destination: GameOverView(score: score, showGameView: $showGameView, category: $category, time: $time, noOfQuestions: $noOfQuestions), isActive: $isGameOver) {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
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

    func fontSize(for text: String) -> CGFloat {
        if text.count < 3 {
            return 90
        } else if text.count < 8 {
            return 50
        } else {
            return 20
        }
    }
    
    func checkAnswer(_ selected: String) {
        timer?.invalidate()
        
        if selected == firebaseViewModel.currentQuestion?.answer {
            score += 10
        }
        
        questionCount += 1
        
        if questionCount < noOfQuestions {
            firebaseViewModel.fetchQuestionAndAnswer(category: category)
            startTimer()
        } else {
            isGameOver = true
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timeRemaining = time
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { tim in
            if timeRemaining <= 0 {
                tim.invalidate()
                self.timer = nil
                self.questionCount += 1
                
                if self.questionCount < self.noOfQuestions {
                    firebaseViewModel.fetchQuestionAndAnswer(category: category)
                    startTimer()
                } else {
                    isGameOver = true
                }
            } else {
                self.timeRemaining -= 0.1
            }
        }
    }
}

