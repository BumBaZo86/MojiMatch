//
//  HomeView.swift
//  MojiMatch
//
//  Created by Camilla Falk on 2025-05-20.
//
import SwiftUI
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("soundOn") private var soundOn = true

    @State var showWheel = false
    @State private var showInfo = false
    @State private var showRules = false
    @State private var navigateToGameSettings = false
    @StateObject private var emojiVM = EmojiViewModel()
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var logoBounce = false
    
    func playButtonSound() {
        guard soundOn else { return }
        
        guard let url = Bundle.main.url(forResource: "buttonsound", withExtension: "mp3") else {
            print("Ljudfilen hittades inte.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Fel vid uppspelning av ljud: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(appSettings.isSettingsMode
                      ? Color(hex: "778472")
                      : Color(red: 113/256, green: 162/256, blue: 114/256))
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Image("MojiMatchLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 270)
                            .foregroundColor(.white)
                            .scaleEffect(logoBounce ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: logoBounce)
                            .onAppear {
                                logoBounce = true
                            }
                        
                        Button(action: {
                            playButtonSound()
                            navigateToGameSettings = true
                        }) {
                            Text("Play")
                                .font(.title2)
                                .padding()
                                .frame(width: 200)
                                .background(Color(red: 186/256, green: 221/256, blue: 186/256))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            playButtonSound()
                            showRules = true
                        }) {
                            Text("Rules")
                                .font(.title2)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            playButtonSound()
                            showInfo = true
                        }) {
                            Text("Info")
                                .font(.title2)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            withAnimation {
                                showWheel = true
                            }
                        }) {
                            SpinningWheelButton()
                        }
                        .padding(.bottom, 5)
                        
                        VStack(spacing: 5) {
                            Text("Random Emoji")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Text(emojiVM.emoji)
                                .font(.system(size: 50))
                        }
                        .padding()
                        .frame(width: 250, height: 110)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(red: 186/256, green: 221/256, blue: 186/256), lineWidth: 7)
                        )
                        .fontDesign(.monospaced)
                        .padding(.bottom, 20)
                        
                        Spacer(minLength: 30)
                        
                        NavigationLink(destination: GameSettingsView(), isActive: $navigateToGameSettings) {
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                if showWheel {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showWheel = false
                            }
                        }
                    
                    WheelView()
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .onAppear {
                emojiVM.fetchEmoji()
                if soundOn {
                    AudioManager.shared.playBackgroundMusic()
                }
            }
            .onDisappear {
                AudioManager.shared.stopBackgroundMusic()
            }
            .sheet(isPresented: $showRules) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🧠 Rules")
                        .font(.title2)
                        .bold()
                    
                    ScrollView {
                        Text("""
Welcome to **MojiMatch** – the ultimate emoji guessing challenge! 🎉

🎯 **Goal**
Guess what a combination of emojis means by choosing the correct matching emoji.

🕹️ **How to Play**
- A series of emojis will appear (e.g., 🍌🌳🙊).
- Choose from 4 emojis what they represent (e.g., 🍌🌳🙊 = 🦍).
- Select before time runs out!

🏆 **Progress & Rewards**
- Earn points for each correct answer.
- Collect more points by spinning the wheel of fortune. 
- Collect stars to buy more spins. 
- Use points to unlock upgrades and new categories.
- See other player's scores on the scoreboard. 

🧠 Can you master the language of emojis?
""")
                        .font(.body)
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        showRules = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(appSettings.isSettingsMode
                                      ? Color(hex: "778472")
                                      : Color(red: 113/256, green: 162/256, blue: 114/256)))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .presentationDetents([.fraction(0.65)])
            }
            .sheet(isPresented: $showInfo) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("ℹ️ Info")
                        .font(.title2)
                        .bold()
                    
                    ScrollView {
                        Text("""
MojiMatch is a creative emoji-guessing game that challenges your brain. 🧠

Think fast, decode emoji puzzles, and level up!

🛠️ Built using SwiftUI  
🌐 Powered by Firebase  
🎨 Designed with love

Can you beat your high score? 🎮
""")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        showInfo = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(appSettings.isSettingsMode
                                      ? Color(hex: "778472")
                                      : Color(red: 113/256, green: 162/256, blue: 114/256)))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .presentationDetents([.fraction(0.65)])
            }
        }
    }

    struct SpinningWheelButton: View {
        @State var rotation: Double = 0
        let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
        
        var body: some View {
            ZStack {
                ForEach(0..<10, id: \.self) { i in
                    SegmentViewButton(label: "", index: i, totalSegments: 10)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .rotationEffect(.degrees(rotation))
            .onReceive(timer) { _ in
                rotation += 0.5
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppSettings())
    }
}
