//
//  isDarkColors.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-02.
//

import SwiftUI

struct ThemeColors {
    static func background(_ isDarkMode: Bool) -> Color {
        isDarkMode ? Color(hex: "778472") : Color(hex: "7CAC7D")
    }

    static func text(_ isDarkMode: Bool) -> Color {
        isDarkMode ? .white : .black
    }
}
