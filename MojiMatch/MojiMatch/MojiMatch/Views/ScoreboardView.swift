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

    var body: some View {
        ZStack {
            Color(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()

            VStack {
                Text("Scoreboard")
                    .headLinesText()

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
            firebaseViewModel.fetchUsers()
        }
    }
}
