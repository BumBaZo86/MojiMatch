//
//  ScoreboardView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct ScoreboardView: View {
    
    @ObservedObject var firebaseViewModel : FirebaseViewModel
    
    var body: some View {
        
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack{
                Text("Scoreboard")
                    .headLinesText()
                
                List(firebaseViewModel.usersAndScores.indices, id: \.self) { users in
                    let user = firebaseViewModel.usersAndScores[users]
                    
                    HStack {
                        
                        Text("#\(users + 1)")
                            .padding()
                        
                        Text(user.username)
                        
                        Spacer()
                        
                        Text(String(user.points))
                            .padding()
                    }
                    .scoreboardListItems()
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            
        }
        .onAppear {
            firebaseViewModel.fetchUsers()
        }
    }
}
