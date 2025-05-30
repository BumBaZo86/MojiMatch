//
//  FirebaseViewModel.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseViewModel: ObservableObject {
    
    @Published var currentQuestion : Question?
    @Published var optionA : String = ""
    @Published var optionB : String = ""
    @Published var optionC : String = ""
    @Published var optionD : String = ""
    
    @Published var username: String = ""
    @Published var points: Int = 0
    
    @Published var usersAndScores: [ScoreboardModel] = []
    
    private var db = Firestore.firestore()
    private var userListener: ListenerRegistration?
    
    init() {
        startUserListener()
    }
    
    func startUserListener() {
        guard let email = Auth.auth().currentUser?.email else { return }
        let userRef = db.collection("users").document(email)
        
        userListener = userRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            if let doc = documentSnapshot, doc.exists {
                DispatchQueue.main.async {
                    self.points = doc["points"] as? Int ?? 0
                    self.username = doc["username"] as? String ?? ""
                }
            }
        }
    }
    
    func addPoints(_ newPoints: Int) {
        guard let email = Auth.auth().currentUser?.email else { return }
        let userRef = db.collection("users").document(email)
        
        userRef.getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let currentPoints = document["points"] as? Int ?? 0
                let updatedPoints = currentPoints + newPoints
                
                userRef.updateData(["points": updatedPoints]) { err in
                    if let err = err {
                        print("Error updating points: \(err.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self?.points = updatedPoints
                        }
                    }
                }
            } else {
                userRef.setData(["points": newPoints]) { err in
                    if let err = err {
                        print("Error setting points: \(err.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self?.points = newPoints
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        userListener?.remove()
    }
    
    
    func fetchQuestionAndAnswer(category : String) {
        db.collection(category).getDocuments() { snapshot, error in
            if let error = error {
                print("Error:: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let allQuestions: [Question] = documents.compactMap { document in
                try? document.data(as: Question.self)
            }
            
            let shuffledQuestions = allQuestions.shuffled()
            guard let correctQuestion = shuffledQuestions.first else { return }
            
            let incorrectAnswers = Array(shuffledQuestions.dropFirst().prefix(3).map { $0.answer })
            
            var answerOptions = ([correctQuestion.answer] + incorrectAnswers).shuffled()
            
            if incorrectAnswers.contains(correctQuestion.answer) {
                self.fetchQuestionAndAnswer(category: category)
                return
            }
            
            let uniqueAnswers = Array(Set(answerOptions)).shuffled()
            guard uniqueAnswers.count == 4 else {
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
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error:: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var userScore : [ScoreboardModel] = []
            
            for document in documents {
                let data = document.data()
                let username = data["username"] as? String ?? "No username"
                let points = data["points"] as? Int ?? 0
                
                let userWithScores = ScoreboardModel(
                    username: username,
                    points: points
                )
                userScore.append(userWithScores)
            }
            
            DispatchQueue.main.async {
                self.usersAndScores = userScore.sorted { $0.points > $1.points }
            }
        }
    }
}
