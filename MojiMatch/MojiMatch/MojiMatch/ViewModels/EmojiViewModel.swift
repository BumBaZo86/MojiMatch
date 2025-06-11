//
//  EmojiViewModel.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-02.
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
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let htmlCodes = json["htmlCode"] as? [String] else {
                DispatchQueue.main.async {
                    self.emoji = "❓"
                }
                return
            }

            let emoji = self.decodeHTMLEntities(htmlCodes)
            DispatchQueue.main.async {
                self.emoji = emoji
            }
        }.resume()
    }

    private func decodeHTMLEntities(_ htmlCodes: [String]) -> String {
        var emoji = ""
        for html in htmlCodes {
            let numberString = html.replacingOccurrences(of: "&#", with: "").replacingOccurrences(of: ";", with: "")
            if let number = UInt32(numberString),
               let scalar = UnicodeScalar(number) {
                emoji.append(String(scalar))
            }
        }
        return emoji.isEmpty ? "❓" : emoji
    }
}
