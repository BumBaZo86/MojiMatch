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
                
                List(firebaseViewModel.usersAndScores.indices, id: \.self) { users in
                    let user = firebaseViewModel.usersAndScores[users]
                    
                    HStack {
                        
                        Text("\(emojiRank(rank: users))")
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
    
    func emojiRank(rank : Int) -> String {
        
        switch rank {
        case 0:
            return "🥇"
        case 1:
            return "🥈"
        case 2:
            return "🥉"
        case 3:
            return "4️⃣"
        case 4:
            return "5️⃣"
        case 5:
            return "6️⃣"
        case 6:
            return "7️⃣"
        case 7:
            return "8️⃣"
        case 8:
            return "9️⃣"
        case 9:
            return "🔟"
        default:
            return "🔹"
        }
        
    }
}
