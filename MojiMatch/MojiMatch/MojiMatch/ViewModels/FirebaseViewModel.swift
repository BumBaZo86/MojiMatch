//
//  FirebaseViewModel.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import Foundation
import Firebase
import FirebaseFirestore


class FirebaseViewModel : ObservableObject {
    
    @Published var currentQuestion : Question?
    @Published var optionA : String = ""
    @Published var optionB : String = ""
    @Published var optionC : String = ""
    @Published var optionD : String = ""
    
   
    @Published var username: String = ""
    @Published var points: Int = 0
   
    @Published var usersAndScores: [ScoreboardModel] = []
    
    
    var db = Firestore.firestore()
    
    func fetchQuestionAndAnswer(category : String) {
        
        db.collection(category).getDocuments() { snapshot, error in
            if let error = error {
                print("Error:: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return}
            
            let allQuestions: [Question] = documents.compactMap { document in
                try? document.data(as: Question.self)
            }
            
            let shuffledQuestions = allQuestions.shuffled()
            let correctQuestion = shuffledQuestions.first!
            
            let incorrectAnswers = Array(shuffledQuestions.dropFirst().prefix(3).map { $0.answer})
            print(incorrectAnswers, correctQuestion.question, correctQuestion.answer)
            
            var answerOptions = ([correctQuestion.answer] + incorrectAnswers).shuffled()
            answerOptions.shuffle()
            
            
            if (incorrectAnswers.contains(correctQuestion.answer)) {
                print("incorrect answers contain correct answer \(incorrectAnswers) and \(correctQuestion.answer)")
                self.fetchQuestionAndAnswer(category: category)
                return
            }
            
            
            //Set filters away duplicates
            let uniqueAnswers = Array(Set(answerOptions)).shuffled()
            
            guard uniqueAnswers.count == 4 else {
                print("Try again. Duplicates found.")
                self.fetchQuestionAndAnswer(category: category)
                return
    
            }
          
            DispatchQueue.main.async {
                self.currentQuestion = correctQuestion
                self.optionA = answerOptions[0]
                self.optionB = answerOptions[1]
                self.optionC = answerOptions[2]
                self.optionD = answerOptions[3]
            }
        }
    }
    
    func fetchUsers() {
        
        db.collection("users").getDocuments(completion:) { snapshot, error in
            if let error = error {
                print("Error:: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return}
            
            var userScore : [ScoreboardModel] = []
            
            for document in documents {
                
                let data = document.data()
                let username = data["username"] as? String ?? "No username"
                let points = data["points"] as? Int ?? 0
                
                
                let userWithScores = ScoreboardModel(
                    
                    username: username,
                    points : points
                   
                )
                
                userScore.append(userWithScores)
                
            }
                DispatchQueue.main.async {
                    self.usersAndScores = userScore.sorted { $0.points > $1.points }
                        }
        }
    }
}
