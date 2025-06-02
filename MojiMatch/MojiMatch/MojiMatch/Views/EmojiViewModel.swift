//
//  EmojiViewModel.swift
//  MojiMatch
//
//  Created by Lina Bergsten on 2025-06-02.
//

import Foundation
import SwiftUI

class EmojiViewModel: ObservableObject {
    @Published var emoji: String = "❓"

    func fetchEmoji() {
        guard let url = URL(string: "https://emojihub.yurace.pro/api/random") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let htmlCodes = json["htmlCode"] as? [String],
               let htmlCode = htmlCodes.first {
                
                let emoji = self.decodeHTMLEntity(htmlCode)
                DispatchQueue.main.async {
                    self.emoji = emoji
                }
            }
        }.resume()
    }

    private func decodeHTMLEntity(_ html: String) -> String {
        guard let number = Int(html.replacingOccurrences(of: "&#", with: "").replacingOccurrences(of: ";", with: "")) else {
            return "❓"
        }
        return String(UnicodeScalar(number) ?? "?")
    }
}
