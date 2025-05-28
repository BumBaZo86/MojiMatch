//
//  UserModel.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-20.
//

import Foundation
import FirebaseAuth


struct MojiMatchUser: Identifiable {
    var id = UUID()
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
        self.points = 0
        self.level = "Easy"
        self.unlockedCategories = ["Animals"]
        self.unlockedLevels = ["Easy"]
        self.unlockedQuestionCounts = [5]
    }

 
    init?(from dict: [String: Any]) {
        guard let email = dict["email"] as? String,
              let username = dict["username"] as? String,
              let points = dict["points"] as? Int,
              let level = dict["level"] as? String,
              let unlockedCategories = dict["unlockedCategories"] as? [String],
              let unlockedLevels = dict["unlockedLevels"] as? [String],
              let unlockedQuestionCounts = dict["unlockedQuestionCounts"] as? [Int] else {
            return nil
        }
        self.email = email
        self.username = username
        self.points = points
        self.level = level
        self.unlockedCategories = unlockedCategories
        self.unlockedLevels = unlockedLevels
        self.unlockedQuestionCounts = unlockedQuestionCounts
    }

 
    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "username": username,
            "points": points,
            "level": level,
            "unlockedCategories": unlockedCategories,
            "unlockedLevels": unlockedLevels,
            "unlockedQuestionCounts": unlockedQuestionCounts
        ]
    }
}
