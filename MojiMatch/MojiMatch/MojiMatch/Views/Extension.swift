//
//  Extenstion.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//

import SwiftUI

extension View {
    
    
    func customGameSettings(isSelected: Bool) -> some View {
        self
        
            .padding()
            .frame(width: 80, height: 80)
            .foregroundStyle(Color.black)
            .background(isSelected ? Color(red: 113/256, green: 162/256, blue: 114/256) : Color.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )
            .fontDesign(.monospaced)
        
    }
    
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
    
    func buttonStyleCustom() -> some View {
        self
            .padding()
            .frame(width: 250, height: 60)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke( Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
        
    }
}
struct CustomGroupStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: 350)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
    }
}

extension View {
    func customGroupStyle() -> some View {
        self.modifier(CustomGroupStyle())
    }
}
