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
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )
            .fontDesign(.monospaced)
    }
    
    func logInSignUpTextField() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .foregroundColor(.black)
            .fontDesign(.monospaced)
            .padding(.horizontal)
            .frame(height: 50)
            
    }
    
    
    func mojiMatchLogo() -> some View {
        
        Image("MojiMatchLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .foregroundColor(.white)
    }
    
    func headLinesText() -> some View {
        self
            .font(.title2)
            .fontDesign(.monospaced)
            .foregroundStyle(.black)
            .padding(8)
            .frame(width: 200, height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 5)
            )
    }
    
    func scoreboardListItems() -> some View {
        self
            .font(.title2)
            .fontDesign(.monospaced)
            .foregroundStyle(.black)
            .frame(width: 350, height: 60)
            .background(Color.white)
            .shadow(radius: 10.0, x: 20, y: 10)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 5)
            )
    }
    
    func customAnswerOptions() -> some View {
        self
            .padding()
            .frame(width: 130, height: 100)
            .foregroundStyle(Color.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
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
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 10)
            )
            .shadow(radius: 10.0, x: 20, y: 10)
            .fontDesign(.monospaced)
            .padding(.top, 20)
    }
    
    func buttonStyleCustom() -> some View {
        self
            .padding()
            .frame(width: 250, height: 60)
            .foregroundStyle(Color.black)
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


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}


