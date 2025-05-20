//
//  HomeView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI

struct HomeView: View {
    
    @State var showGameView = false
    
    var body: some View {
        
        ZStack{
            
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack{
                Text("HomeView")
                
                Spacer()
                
                Button(action: {
                    showGameView = true }) {
                        Text("Play")
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
                        
                    }
                Spacer()
            }
            .fullScreenCover(isPresented: $showGameView){
                GameView(firebaseViewModel: FirebaseViewModel())
            }
        }
    }
}

#Preview {
    HomeView()
}
