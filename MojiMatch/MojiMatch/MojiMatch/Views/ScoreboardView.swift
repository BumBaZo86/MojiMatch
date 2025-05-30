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
    
    @ObservedObject var firebaseViewModel: FirebaseViewModel
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var selectedFilter = "Today"
    private let filters = ["Today", "Week", "Month", "All time"]
    
    var body: some View {
        ZStack {
            //backgroundcolor depending of settings.
            Color(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()
            
            VStack {
                Text("Scoreboard")
                    .headLinesText()
                    .padding(.top)
                
                Picker("Filter", selection: $selectedFilter) {
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
                
                List(firebaseViewModel.usersAndScores.indices, id: \.self) { index in
                    let user = firebaseViewModel.usersAndScores[index]
                    
                    HStack {
                        Text("#\(index + 1)")
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
            firebaseViewModel.fetchUsers(filter: selectedFilter)
        }
        .onChange(of: selectedFilter) { newFilter in
            firebaseViewModel.fetchUsers(filter: newFilter)
        }
    }
}
