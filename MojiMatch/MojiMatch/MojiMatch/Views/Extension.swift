//
//  Extenstion.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI

extension View {
    func customAnswerOptions() -> some View {
        self
            .padding()
            .frame(width: 130, height: 100)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
            )
            .fontDesign(.monospaced)
    }

    func customQuestionText() -> some View {
        self
            .padding()
            .frame(width: 300, height: 200)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
            .padding(.top, 100)
    }
}
