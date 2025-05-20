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
    
    var body: some View {
        
        ZStack{
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
           
            VStack{
                Spacer()
            
                if let question = firebaseViewModel.currentQuestion {
                    
                    Text(question.question)
                        .padding()
                        .frame(width: 300, height: 100)
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
                                Button(firebaseViewModel.optionA) {
                                    checkAnswer(firebaseViewModel.optionA)
                                }
                                .customAnswerOptions()
                                
                                Button(firebaseViewModel.optionB) {
                                    checkAnswer(firebaseViewModel.optionB)
                                }
                                .customAnswerOptions()
                                
                                
                                Spacer()
                            }
                            
                            HStack (spacing: 25){
                                Spacer()
                                Button(firebaseViewModel.optionC) {
                                    checkAnswer(firebaseViewModel.optionC)                                }
                                .customAnswerOptions()
                                
                                Button(firebaseViewModel.optionD) {
                                    checkAnswer(firebaseViewModel.optionD)
                                }
                                .customAnswerOptions()
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear{
            firebaseViewModel.fetchQuestionAndAnswer()
        }
    }
    
    func checkAnswer(_ selected: String) {
        
        if selected == firebaseViewModel.currentQuestion?.answer {
            
            print("Correct")
            
            firebaseViewModel.fetchQuestionAndAnswer()
            
        } else {
            print("Wrong")
            
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

            .fontDesign(.monospaced)
    }
    
}
