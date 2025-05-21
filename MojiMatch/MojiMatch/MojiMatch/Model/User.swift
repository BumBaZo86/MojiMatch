//
//  UserModel.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-20.
//

import Foundation
import FirebaseAuth

struct MojiMatchUser {
    var email: String
    var username: String
    var points: Int
    var level: String
    var unlockedCategories: [String]
    var unlockedLevels: [String]
    var unlockedQuestionCounts: [Int]
    
    // Initializer från FirebaseAuth.User
    init(from firebaseUser: FirebaseAuth.User) {
        self.email = firebaseUser.email ?? ""
        self.username = firebaseUser.displayName ?? "Anonymous"
        self.points = 0  // Du kan sätta ett standardvärde eller hämta det från Firestore om det finns
        self.level = "Easy"  // Standardvärde
        self.unlockedCategories = ["Animals"]  // Standardvärde
        self.unlockedLevels = ["Easy"]  // Standardvärde
        self.unlockedQuestionCounts = [5]  // Standardvärde
    }
}
