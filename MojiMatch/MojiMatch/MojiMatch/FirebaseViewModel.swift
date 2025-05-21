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
            
            let incorrectAnswers = shuffledQuestions.dropFirst().prefix(3).map { $0.answer}
            
            var answerOptions = ([correctQuestion.answer] + incorrectAnswers).shuffled()
            answerOptions.shuffle()
            
            
            DispatchQueue.main.async {
                self.currentQuestion = correctQuestion
                self.optionA = answerOptions[0]
                self.optionB = answerOptions[1]
                self.optionC = answerOptions[2]
                self.optionD = answerOptions[3]
            }
        }
    }
}
