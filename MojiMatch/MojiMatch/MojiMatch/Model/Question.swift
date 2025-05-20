//
//  Question.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Question : Codable, Identifiable {
    
    @DocumentID var id : String?
    var question : String
    var answer : String
  
}
