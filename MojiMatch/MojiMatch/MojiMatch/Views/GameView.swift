//
//  GameView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//
//
import SwiftUI
import Firebase
import FirebaseFirestore
import AVFoundation

struct GameView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var firebaseViewModel = FirebaseViewModel()
    
    @Binding var category: String
    @Binding var time: Double
    @Binding var noOfQuestions: Int
    @Binding var maxPoints: Int
    @Binding var showGameView: Bool
    
    @AppStorage("soundOn") private var soundOn = true
    
    @State var questionCount = 0
    @State var score = 0
    @State private var isGameOver = false
    @State var timeRemaining = 10.0
    @State var timer: Timer?
    
    @State var selectedAnswer : String? = nil
    @State var isAnswerCorrect : Bool? = nil
    
    @State var starOne: Bool = false
    @State var starTwo: Bool = false
    @State var starThree: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                (appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 124/255, green: 172/255, blue: 125/255))
                    .ignoresSafeArea()
                
                VStack {
                    VStack {
                        Text("Score: \(score)")
                            .foregroundColor(.black)
                        
                        ZStack {
                            ProgressView(value: Double(score), total: Double(noOfQuestions * maxPoints))
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(Color(red: 113/255, green: 162/255, blue: 114/255))
                                .scaleEffect(y: 2)
                                .padding(.horizontal)
                            
                            GeometryReader { geometry in
                                let width = geometry.size.width
                                Group {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: starOne ? 45 : 25, height: starOne ? 45 : 25)
                                        .position(x: width * 0.2, y: 7)
                                        .foregroundStyle(starOne ? Color.yellow : Color.gray)
                                    
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: starTwo ? 45 : 25, height: starTwo ? 45 : 25)
                                        .position(x: width * 0.6, y: 7)
                                        .foregroundStyle(starTwo ? Color.yellow : Color.gray)
                                    
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: starThree ? 45 : 25, height: starThree ? 45 : 25)
                                        .position(x: width, y: 7)
                                        .foregroundStyle(starThree ? Color.yellow : Color.gray)
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal)
                        }
                        .frame(height: 40)
                    }
                    .padding()
                    .frame(width: 350, height: 100)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 10)
                    )
                    .shadow(radius: 10, x: 20, y: 10)
                    .fontDesign(.monospaced)
                    .padding(.top)
                    
                    if let question = firebaseViewModel.currentQuestion {
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: fontSize(for: question.question)))
                            .foregroundColor(.black)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .frame(width: 350, height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 7)
                                )
                            
                            VStack(spacing: 25) {
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
                            }
                        }
                        .padding(.top, 20)
                        
                        HStack {
                            Spacer()
                            Text(String(format: "%02d:%02d", Int(ceil(timeRemaining)) / 60, Int(ceil(timeRemaining)) % 60))
                                .padding(.horizontal)
                                .padding(.top)
                                .foregroundColor(.black)
                        }
                        
                        ProgressView(value: max(0, timeRemaining), total: time)
                            .progressViewStyle(LinearProgressViewStyle())
                            .tint(.black)
                            .padding(.horizontal)
                            .padding(.bottom, 50)
                    }
                    
                    NavigationLink(
                        destination: GameOverView(
                            score: $score,
                            showGameView: $showGameView,
                            category: $category,
                            time: $time,
                            noOfQuestions: $noOfQuestions,
                            maxPoints: $maxPoints,
                            starOne: $starOne,
                            starTwo: $starTwo,
                            starThree: $starThree
                        ),
                        isActive: $isGameOver
                    ) {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
                
                if soundOn {
                    SoundManager.shared.playButtonSound()
                    SoundManager.shared.playGameMusic()
                }
            }
            .onChange(of: soundOn) { oldValue, newValue in
                if newValue {
                    SoundManager.shared.playGameMusic()
                } else {
                    SoundManager.shared.stopGameMusic()
                }
            }
            .onDisappear {
                timer?.invalidate()
                // Musik stoppas INTE här – låt soundOn styra ljudet globalt
            }
        }
    }
    
    func optionButton(text: String) -> some View {
        Button(action: {
            if soundOn {
                SoundManager.shared.playButtonSound()
            }
            checkAnswer(text)
        }) {
            Text(text)
                .foregroundColor(.black)
        }
        .customAnswerOptions(backgroundColor: buttonBackgroundColor(for: text))
        .font(.system(size: text.count < 2 ? 70 : 10))
    }
    
    func buttonBackgroundColor(for text: String) -> Color {
        
        if let selected = selectedAnswer {
            if selected == text {
                return isAnswerCorrect == true ? Color.green : Color.red
            } else {
                return Color.white.opacity(0.5)
            }
        } else {
            return Color.white
        }
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
        
        selectedAnswer = selected
        isAnswerCorrect = (selected == firebaseViewModel.currentQuestion?.answer)
        
        if isAnswerCorrect == true {
            if time == 5.0 {
                score += 30
            } else if time == 7.0 {
                score += 20
            } else {
                score += 10
            }
        }
        
        checkStars()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){
            
            selectedAnswer = nil
            isAnswerCorrect = nil
            
            questionCount += 1
            
            if questionCount < noOfQuestions {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
            } else {
                isGameOver = true
            }
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
    
    func checkStars() {
        let total = maxPoints * noOfQuestions
        if score >= total {
            starThree = true
        } else if score >= total * 3 / 5 {
            starTwo = true
        } else if score >= total / 5 {
            starOne = true
        }
    }
}
