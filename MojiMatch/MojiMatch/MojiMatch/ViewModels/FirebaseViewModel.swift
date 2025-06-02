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
    
    
    /**
     * Fetch question and the answer to that question.
     * Fetch 3 more incorrect answers.
     * Checks that all 4 answer options are unique so user dont get duplicates.
     */
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
    
    /**
     * Fetch users and thair scores.
     * Runs FetchTotalScores()
     * Sorts highest score highest and then in decending order.
     */
    
    func fetchUsers(filter : String = "All time") {
        
        db.collection("users").getDocuments(completion:) { snapshot, error in
            if let error = error {
                print("Error:: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return}
            
            var userScore : [ScoreboardModel] = []
            
            //DispatchGroup() makes the fetching of all user scores finish before continuing.
            let group = DispatchGroup()
            
            for document in documents {
                
                let data = document.data()
                let username = data["username"] as? String ?? "No username"
                let email = document.documentID
                
                
                group.enter() //start collecting scores.
                self.fetchTotalScores(for: email, filter: filter) { total in
                    let userWithScores = ScoreboardModel(username: username, points : total)
                    userScore.append(userWithScores)
                    group.leave() //Done collecting scores.
                }
               
                //Sorting scores highest to lowest.
                group.notify(queue: .main) {
                    self.usersAndScores = userScore.sorted { $0.points > $1.points }
                }
            }
        }
    }
    
    /**
     * Fetch and filters the scores in today, week, months.
     */
    
    func fetchTotalScores(for email: String, filter: String, completion: @escaping (Int) -> Void) {
        
        var dbRef : Query = db.collection("users").document(email).collection("gameScore")
        let calendar = Calendar.current
        let today = Date()
        var startDate : Date?
        
        switch filter {
            
        case "Today":
            startDate = calendar.startOfDay(for: today)
            
        case "Week":
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))
            
        case "Month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
            
        default:
            startDate = nil
        }
        
        // Filters scores with timestamp >= startDate
        if let start = startDate {
            dbRef = dbRef.whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: start))
        }
        
        dbRef.getDocuments { snapshot, error in
            
            if let error = error {
                print("Error fetching scores for \(email): \(error.localizedDescription)")
                completion(0)
                return
            }
            
            // Adds all the scores together that is fetched with the correct filter. Eg. Today user has played 3 games with scores
            // [20, 50, 30]. Scores are added together to 100. Todays total score is 100 and is shown on scoreboard.
            let scores = snapshot?.documents.compactMap { $0.data()["gameScore"] as? Int } ?? []
            completion(scores.reduce(0, +))
        }
    }
}
