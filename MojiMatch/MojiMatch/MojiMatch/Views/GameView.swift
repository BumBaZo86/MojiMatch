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
                            .padding(.top, 50)                            .fontDesign(.monospaced)
                    }
                    
                    //Fetch game question and show it.
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
                            
                            //Show answerOptions as buttons
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
                        
                        //Active timer show ticking down in MM:SS format.
                        HStack {
                            Spacer()
                            Text(String(format: "%02d:%02d", Int(ceil(timeRemaining)) / 60, Int(ceil(timeRemaining)) % 60))
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        
                        //Progressbar works together with the timer to show remaining time.
                        ProgressView(value: max(0, timeRemaining), total: time)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.black)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 90)
                    
                    //Navigate to GameOverView after game over.
                    NavigationLink(destination: GameOverView(score: score, showGameView: $showGameView, category: $category, time: $time, noOfQuestions: $noOfQuestions), isActive: $isGameOver) {
                        EmptyView()
                    }
                }
            }
            //Fetch first question, answerOptions and start timer.
            .onAppear {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
            }
        }
    }
    
    
    /**
     * Show answerOptions
     * Check if answer is correct
     * Adapt text size depending on how many characters each string has.
    
     */
    func optionButton(text: String) -> some View {
        Button(action: {
            checkAnswer(text)
        }) {
            Text(text)
        }
        .customAnswerOptions()
        .font(.system(size: text.count < 2 ? 70 : 10))
    }

    /**
     * Adapts the text size depending on how many characters each string has.
     */
    func fontSize(for text: String) -> CGFloat {
        if text.count < 3 {
            return 90
        } else if text.count < 8 {
            return 50
        } else {
            return 20
        }
    }
    
    /**
     * Check if answer is correct or not
     * If correct = score + 10 points.
     * After question is answered, either a new question is fetched or GameOverView is shown.
     * New timer starts again if a new question is fetched.
     */
    
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
    
    
    /**
     * Timer starts.
     * If a timer is already running, stops it and then starts a new one.
     * If timer runs out of time, checks if a new question is being fetched or if it is GameOver.
     * Updates every 0.1 seconds. 
     */
    
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


