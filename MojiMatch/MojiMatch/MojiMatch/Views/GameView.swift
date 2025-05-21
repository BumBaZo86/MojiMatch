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
    @Binding var time : Double
    @Binding var noOfQuestions : Int
    @State var questionCount = 0
    @State var score = 0
    
    @State var timeRemaining = 10.0
    
    @State var timer : Timer?
    
    var body: some View {
        
        ZStack{
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
           
            VStack{
                Spacer(minLength: 50)
                HStack {
                    Spacer()
                    Text("Score: \(score)")
                        .padding()
                        .fontDesign(.monospaced)
                    
                }
                                
                if let question = firebaseViewModel.currentQuestion {
                    
                    if (question.question.count < 3){
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: 90))
                            
                    } else if (question.question.count > 2 && question.question.count < 8) {
                        
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: 50))
                        
                        
                    } else if (question.question.count > 7) {
                        Text(question.question)
                            .customQuestionText()
                            .font(.system(size: 20))
                        
                    }
                    Spacer(minLength: 80)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: 350, height: 300)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                            )
                        
                        VStack (spacing: 25){
                           Spacer()
                            HStack (spacing: 25){
                                Spacer()
                                
                                if (firebaseViewModel.optionA.count < 2){
                                    Button(firebaseViewModel.optionA) {
                                        checkAnswer(firebaseViewModel.optionA)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 70))
                                } else {
                                    Button(firebaseViewModel.optionA) {
                                        checkAnswer(firebaseViewModel.optionA)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 10))
                                }
                                
                                if (firebaseViewModel.optionB.count < 2){
                                    Button(firebaseViewModel.optionB) {
                                        checkAnswer(firebaseViewModel.optionB)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 70))
                                } else {
                                    Button(firebaseViewModel.optionB) {
                                        checkAnswer(firebaseViewModel.optionB)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 10))
                                }
                                
                                
                                Spacer()
                            }
                            
                            HStack (spacing: 25){
                                Spacer()
                                if (firebaseViewModel.optionC.count < 2){
                                    Button(firebaseViewModel.optionC) {
                                        checkAnswer(firebaseViewModel.optionC)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 70))
                                } else {
                                    Button(firebaseViewModel.optionC) {
                                        checkAnswer(firebaseViewModel.optionC)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 10))
                                }
                                
                                
                                if (firebaseViewModel.optionD.count < 2){
                                    Button(firebaseViewModel.optionD) {
                                        checkAnswer(firebaseViewModel.optionD)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 70))
                                } else {
                                    Button(firebaseViewModel.optionD) {
                                        checkAnswer(firebaseViewModel.optionD)
                                    }
                                    .customAnswerOptions()
                                    .font(.system(size: 10))
                                }
                                
                                Spacer()
                            }
                            
                            
                            
                           Spacer()
                        }
                      
                    }
                    HStack{
                        Spacer()
                        Text(String(format: "%02d:%02d", Int(ceil(timeRemaining)) / 60, Int(ceil(timeRemaining)) % 60))
                            .padding(.horizontal)
                            .padding(.top)
                    }
                   
                    ProgressView(value: Double(timeRemaining), total: Double(time))
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.black)
                        .padding(.horizontal)
                }
                Spacer(minLength: 90)
            }
           
        }
        .onAppear{
            firebaseViewModel.fetchQuestionAndAnswer(category: category)
            startTimer()
        }
    }
    
    func checkAnswer(_ selected: String) {
        
        if selected == firebaseViewModel.currentQuestion?.answer {
            
            print("Correct")
            
            questionCount += 1
            score += 10
            print(questionCount)
            
            if (noOfQuestions > questionCount) {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
            } else {
                print("Game over")
                
                //GO TO GAMEOVERVIEW
            }
            
        } else {
            print("Wrong")
            questionCount += 1
            print(questionCount)
            
            if (noOfQuestions > questionCount) {
                firebaseViewModel.fetchQuestionAndAnswer(category: category)
                startTimer()
            } else {
                
                print("Game over")
                //GO TO GAMEOVERVIEW
            }
            
        }
    }
    
    func startTimer() {
        
        timer?.invalidate()
        timeRemaining = time
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { tim in
           
            if (timeRemaining <= 0) {
                tim.invalidate()
                self.timer = nil
                self.questionCount += 1
                print(self.questionCount)
                
                if (self.noOfQuestions > self.questionCount) {
                    firebaseViewModel.fetchQuestionAndAnswer(category: category)
                    startTimer()
                } else {
                    
                    print("Game over")
                    //GO TO GAMEOVERVIEW
                }
            } else {
                self.timeRemaining -= 0.1
            }
        }
    }
}


extension View {
    
    func customAnswerOptions () -> some View {
        
        self
            .padding()
            .frame(width: 130, height: 100)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke( Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
            
    }
    
    func customQuestionText () -> some View {
        
        
        self
            .padding()
            .frame(width: 300, height: 200)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke( Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
            .padding(.top, 100)
    }
    
}
