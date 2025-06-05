//
//  WheelViewModel.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-06-04.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class WheelViewModel : ObservableObject {
    
    
    @Published var winnerIndex : Int?
    @Published var winner : Int?
    @Published var hasSpunToday = false
    @Published var showWinning = false
    @Published var points : Int?
    @Published var stars : Int?
    @Published var isSpinning = false
    @Published var rotation : Double = 0.0
    @Published var isLoading = true
    
    let segments = ["100", "300", "600", "400", "900", "500", "200", "700", "1000","800"]
    
    
    func buyASpin() {
            
            guard let userEmail = Auth.auth().currentUser?.email else {
                print("No logged in user.")
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userEmail)
            
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    if let currentStars = self.stars, currentStars >= 20 {
                        let newStars = currentStars - 20
                        userRef.updateData(["stars": newStars]) { error in
                            if let error = error {
                                print("Error updating stars: \(error.localizedDescription)")
                            } else {
                                self.stars = newStars
                                self.hasSpunToday = false
                                self.showWinning = false
                                self.spinWheel(isFreeSpin: false)
                            }
                        }
                    }
                }
            }
        }
    
    func checkSpinStatus() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No logged in user.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if let timestamp = document["lastFreeSpin"] as? Timestamp {
                    let lastSpin = timestamp.dateValue()
                    let calendar = Calendar.current
                    self.hasSpunToday = calendar.isDateInToday(lastSpin)
                }
                
                if let fetchPoints = document["points"] as? Int {
                    self.points = fetchPoints
                }
                
                if let fetchStars = document["stars"] as? Int {
                    self.stars = fetchStars
                }
                
            }
            self.isLoading = false
        }
    }
    
    func saveWheelWin(isFreeSpin: Bool) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("No logged in user.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let previousPoints = document["points"] as? Int ?? 0
                let newPoints = previousPoints + (self.winner ?? 0)
                
                var data: [String: Any] = ["points": newPoints]
                            if isFreeSpin {
                                data["lastFreeSpin"] = Timestamp(date: Date())
                            }
                
                userRef.updateData(data) { err in
                    if let err = err {
                        print("Error updating points: \(err.localizedDescription)")
                    } else {
                        self.points = newPoints
                    }
                }
            } else {
                
                var data: [String: Any] = ["points": self.winner ?? 0]
                            if isFreeSpin {
                                data["lastFreeSpin"] = Timestamp(date: Date())
                            }
                userRef.setData(data, merge: true) { err in
                    if let err = err {
                        print("Error setting points: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func spinWheel(isFreeSpin : Bool) {
            isSpinning = true
            let randomRotation = Double.random(in: 1720...2440)
            rotation += randomRotation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
                
                let normalizedRotation = self.rotation.truncatingRemainder(dividingBy: 360)
                let anglePerSegment = 360 / Double(self.segments.count)
                
                let adjustRotation = (360 - normalizedRotation + anglePerSegment / 2).truncatingRemainder(dividingBy: 360)
                
                let index = Int(adjustRotation / anglePerSegment) % self.segments.count
                self.winnerIndex = index
                
                print("Winner \(self.segments[index])")
                
                self.winner = Int(self.segments[index])
                
                self.saveWheelWin(isFreeSpin: isFreeSpin)
                self.showWinning = true
                self.hasSpunToday = isFreeSpin
                self.isSpinning = false
                self.checkSpinStatus()
        }
    }
    
    
}
