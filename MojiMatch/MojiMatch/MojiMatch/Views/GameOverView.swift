//
//  GameOverView.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-05-21.
//
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import ConfettiSwiftUI
import AVFoundation

struct GameOverView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    @Binding var score: Int
    @Binding var showGameView: Bool
    @Binding var category: String
    @Binding var time: Double
    @Binding var noOfQuestions: Int
    @Binding var maxPoints: Int
    @Binding var starOne: Bool
    @Binding var starTwo: Bool
    @Binding var starThree: Bool
    @State var starCount = 0
    
    @State private var showStarOne = false
    @State private var showStarTwo = false
    @State private var showStarThree = false
    @State private var confettiTrigger = false
    
    @State private var gameEndPlayer: AVAudioPlayer?
    @State private var starPlayer: AVAudioPlayer?
    @State private var wellDonePlayer: AVAudioPlayer?
    @State private var buttonPlayer: AVAudioPlayer?  // <-- Knappljudspelare
    
    @State private var wellDoneScale: CGFloat = 0.5
    @State private var visibleCharacters = 0
    
    @State private var showCoin = false
    @State private var coinOffset: CGFloat = 0
    @State private var coinOpacity: Double = 1.0
    
    @AppStorage("soundOn") private var soundOn = true  // Ljudinställning från SettingsView
    
    let wellDoneText = "Well done!"
    
    var body: some View {
        ZStack {
            Color(appSettings.isSettingsMode ? Color(hex: "778472") : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()
            
            ConfettiCannon(trigger: $confettiTrigger, num: 50, radius: 300)
                .position(x: UIScreen.main.bounds.width / 2, y: 50)
            
            VStack(spacing: 30) {
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(0..<wellDoneText.count, id: \.self) { index in
                        let char = Array(wellDoneText)[index]
                        Text(String(char))
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .opacity(index < visibleCharacters ? 1 : 0)
                            .animation(.easeIn(duration: 0.3).delay(Double(index) * 0.1), value: visibleCharacters)
                    }
                }
                .padding()
                .scaleEffect(wellDoneScale)
                .animation(.easeOut(duration: 1.2), value: wellDoneScale)
                .onAppear {
                    wellDoneScale = 1.2
                    animateText()
                }
                
                HStack {
                    Spacer()
                    if showStarOne {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(Color.yellow)
                            .transition(.scale)
                    }
                    if showStarTwo {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(Color.yellow)
                            .transition(.scale)
                    }
                    if showStarThree {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(Color.yellow)
                            .transition(.scale)
                    }
                    Spacer()
                }
                .padding()
                
                Text("Your score: \(score) !!")
                    .font(.title2)
                    .foregroundColor(.black)
                    .onAppear {
                        showCoin = false
                        coinOffset = 0
                        coinOpacity = 1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showCoin = true
                            withAnimation(.easeOut(duration: 1.5)) {
                                coinOffset = -100
                                coinOpacity = 0
                            }
                        }
                    }
                
                if showCoin {
                    Image("coin")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .offset(y: coinOffset)
                        .opacity(coinOpacity)
                        .transition(.opacity)
                }
                
                NavigationLink(destination: GameView(
                    category: $category,
                    time: $time,
                    noOfQuestions: $noOfQuestions,
                    maxPoints: $maxPoints,
                    showGameView: $showGameView
                )) {
                    Text("Play Again")
                        .buttonStyleCustom()
                }
                .onTapGesture {
                    playButtonSound()
                }
                
                Button("Close game") {
                    playButtonSound()
                    showGameView = false
                }
                .buttonStyleCustom()
                
                Spacer()
            }
            .padding(-10)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
            )
            .padding()
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            SoundManager.shared.stopGameMusic()
            
            playGameEndSound()
            playWellDoneSound()
            starAnimation()
            saveGameData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                confettiTrigger = true
            }
        }
    }
    
    func animateText() {
        visibleCharacters = 0
        for i in 1...wellDoneText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                visibleCharacters = i
            }
        }
    }
    
    func playGameEndSound() {
        guard soundOn else { return }
        guard let url = Bundle.main.url(forResource: "gameend", withExtension: "wav") else {
            print("Ljudfilen gameend.wav hittades inte.")
            return
        }
        do {
            gameEndPlayer = try AVAudioPlayer(contentsOf: url)
            gameEndPlayer?.play()
        } catch {
            print("Kunde inte spela upp gameend-ljudet: \(error.localizedDescription)")
        }
    }
    
    func playStarSound() {
        guard soundOn else { return }
        guard let url = Bundle.main.url(forResource: "starbell", withExtension: "mp3") else {
            print("Ljudfilen starbell.mp3 hittades inte.")
            return
        }
        do {
            starPlayer = try AVAudioPlayer(contentsOf: url)
            starPlayer?.play()
        } catch {
            print("Kunde inte spela upp starbell-ljudet: \(error.localizedDescription)")
        }
    }
    
    func playWellDoneSound() {
        guard soundOn else { return }
        guard let url = Bundle.main.url(forResource: "gameoversound", withExtension: "wav") else {
            print("Ljudfilen gameoversound.wav hittades inte.")
            return
        }
        do {
            wellDonePlayer = try AVAudioPlayer(contentsOf: url)
            wellDonePlayer?.play()
        } catch {
            print("Kunde inte spela upp gameoversound-ljudet: \(error.localizedDescription)")
        }
    }
    
    func playButtonSound() {
        guard soundOn else { return }
        guard let url = Bundle.main.url(forResource: "buttonsound", withExtension: "mp3") else {
            print("Ljudfilen buttonsound.mp3 hittades inte.")
            return
        }
        do {
            buttonPlayer = try AVAudioPlayer(contentsOf: url)
            buttonPlayer?.play()
        } catch {
            print("Kunde inte spela upp knappljudet: \(error.localizedDescription)")
        }
    }
    
    func saveGameData() {
        if starOne { starCount += 1 }
        if starTwo { starCount += 1 }
        if starThree { starCount += 1 }
        
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
                let stars = document["stars"] as? Int ?? 0
                userRef.updateData(["points": previousPoints + score, "stars": stars + starCount]) { err in
                    if let err = err {
                        print("Error updating points: \(err.localizedDescription)")
                    }
                }
            } else {
                userRef.setData(["points": score, "stars": starCount], merge: true) { err in
                    if let err = err {
                        print("Error setting points: \(err.localizedDescription)")
                    }
                }
            }
        }
        
        let gameDetails = "Category: \(category), Time: \(Int(time)) sec, Questions: \(noOfQuestions), Points: \(score)"
        let gameScoreList = ["gameScore": score, "timestamp": Timestamp()] as [String: Any]
        let recentGame = ["gameDetails": gameDetails, "timestamp": Timestamp()] as [String: Any]
        
        userRef.collection("gameScore").addDocument(data: gameScoreList) { err in
            if let err = err {
                print("Error saving recent game score: \(err.localizedDescription)")
            }
        }
        
        userRef.collection("recentGames").addDocument(data: recentGame) { err in
            if let err = err {
                print("Error saving recent game: \(err.localizedDescription)")
            }
        }
    }
    
    func starAnimation() {
        if starOne {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showStarOne = true
                    playStarSound()
                }
            }
        }
        if starTwo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showStarTwo = true
                    playStarSound()
                }
            }
        }
    }
}
