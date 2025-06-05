//
//  EmojiConverterViewModel.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-06-05.
//

import Foundation


class EmojiConverterViewModel : ObservableObject {
    
    func textToEmoji(for category: String) -> String {
        switch category {
        case "Animals": return "🦁"
        case "Flags": return "🇬🇶"
        case "Countries": return "🌍"
        case "Food": return "🍝"
        case "Riddles": return "❓"
        case "Movies": return "🎥"
        case "Easy": return "🍼"
        case "Medium": return "😐"
        case "Hard": return "🔥"
        case "5": return "5️⃣"
        case "10": return "🔟"
        case "15": return "1️⃣5️⃣"
        default: return "❔"
        }
    }
    
    func emojiRank(rank : Int) -> String {
            
            switch rank {
            case 0:
                return "🥇"
            case 1:
                return "🥈"
            case 2:
                return "🥉"
            case 3:
                return "4️⃣"
            case 4:
                return "5️⃣"
            case 5:
                return "6️⃣"
            case 6:
                return "7️⃣"
            case 7:
                return "8️⃣"
            case 8:
                return "9️⃣"
            case 9:
                return "🔟"
            default:
                return "🔹"
            }
            
        }
    
    
}
