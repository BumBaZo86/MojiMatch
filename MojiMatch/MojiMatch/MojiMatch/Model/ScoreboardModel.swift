//
//  ScoreboardModel.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-27.
//

import Foundation

struct ScoreboardModel : Identifiable {
    
    var id = UUID()
    var username : String
    var points : Int
}
