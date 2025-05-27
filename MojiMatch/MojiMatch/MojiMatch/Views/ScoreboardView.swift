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
    
    @State var selectedFilter = "Today"
    let filters = ["Today", "Week", "Month", "All time"]
    
    @ObservedObject var firebaseViewModel : FirebaseViewModel
    
    var body: some View {
        
        ZStack {
            Color(red: 113/256, green: 162/256, blue: 114/256)
                .ignoresSafeArea()
            
            VStack{
                Text("Scoreboard")
                    .headLinesText()
            
                Picker("filters", selection: $selectedFilter){
                    ForEach(filters, id: \.self) { filter in
                        Text(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 186/255, green: 221/255, blue: 186/255), lineWidth: 5)
                )
                .padding()
                
                Spacer()
            }
            
        }
        .onAppear {
            firebaseViewModel.fetchUsersAndScores()
        }
    }
}
