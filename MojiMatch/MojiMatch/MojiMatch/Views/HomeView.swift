//
//  HomeView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
struct HomeView: View {
    
    @State var showGameView = false
    @State var category = "Animals"
    @State var time = 10.0
    @State var noOfQuestions = 5
 
    
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
                            .buttonStyleCustom()
                    }
                Spacer()
            }
            // fullscreen makes tabview dissapear during the game and gameOverView. 
            .fullScreenCover(isPresented: $showGameView){
                GameView(firebaseViewModel: FirebaseViewModel(), category: $category, time: $time, noOfQuestions: $noOfQuestions, showGameView: $showGameView)
            }
        }
    }
}

#Preview {
    HomeView()
}
