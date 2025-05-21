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
    
  
    init(from firebaseUser: FirebaseAuth.User) {
        self.email = firebaseUser.email ?? ""
        self.username = firebaseUser.displayName ?? "Anonymous"
        self.points = 0  // get from Firebase, need testing
        self.level = "Easy"  // default
        self.unlockedCategories = ["Animals"]  // default
        self.unlockedLevels = ["Easy"]  // get upd when purchase, need testing
        self.unlockedQuestionCounts = [5]  // default
    }
}
