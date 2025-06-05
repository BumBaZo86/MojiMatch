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
                            .frame(width: 300, height: 300)
                            .foregroundColor(.white)
                            .padding(.bottom, -65)
                        
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
                        
                        Button(action:  {
                            withAnimation {
                                showWheel = true
                            }
                        }) {
                            SpinningWheelButton()
                        }
                        .padding(.bottom, 5)
                        
                        VStack(spacing: 5) {
                            Text("Emoji of the Day")
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
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
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
            
            // Rules sheet
            .sheet(isPresented: $showRules) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🧠 Rules")
                        .font(.largeTitle)
                        .bold()
                    Text("""
1. Choose a category and the number of questions.
2. Each question has four answer options – pick the correct one before time runs out.
3. You earn 10 points for every correct answer.
4. The game ends when all questions are answered or the timer reaches zero.

Think fast and aim for a high score!
""")
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
            }

          
            .sheet(isPresented: $showInfo) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("ℹ️ Info")
                        .font(.largeTitle)
                        .bold()
                    Text("""
MojiMatch is a fast-paced quiz game designed to challenge your memory and reaction time.

Choose your category, race against the clock, and see how high you can score!

The app is built with SwiftUI and uses Firebase to fetch live quiz questions.

👾 Created with passion by [Your Name].
""")
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
            }
        }
    }

    
    struct SpinningWheelButton : View {
        
        @State var rotation : Double = 0
        
        let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
        
        var body : some View {
            ZStack{
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
