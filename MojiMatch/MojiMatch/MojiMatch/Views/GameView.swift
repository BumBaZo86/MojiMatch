//
//  GameView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI

struct GameView: View {
    
    @State var question = "what is...."
    
    var body: some View {
        
        ZStack{
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
           
            VStack{
                Spacer()
            
                Text(question)
                    .padding()
                    .frame(width: 250, height: 60)
                    .foregroundStyle(Color.black)
                    .background(Color.white)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke( Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
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
                            Button("A") {
                                //check if answer is correct
                            }
                            .customAnswerOptions()
                            
                            Button("B") {
                                //check if answer is correct
                            }
                            .customAnswerOptions()
                            
                            
                            Spacer()
                        }
                        
                        HStack (spacing: 25){
                            Spacer()
                            Button("C") {
                                //check if answer is correct
                            }
                            .customAnswerOptions()
                            
                            Button("D") {
                                //check if answer is correct
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
}

#Preview {
    GameView()
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
                    .stroke( Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )

            .fontDesign(.monospaced)
    }
    
}
