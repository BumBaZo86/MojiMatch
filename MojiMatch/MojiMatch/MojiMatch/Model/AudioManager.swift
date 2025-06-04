//
//  AudioManager.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-02.
//

import Foundation
import AVFoundation

//sound manager for HomeView
class AudioManager {
    static let shared = AudioManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("Musikfilen background.mp3 kunde inte hittas.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Kunde inte spela musik: \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}

//sound manager for GameView


class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    func playGameMusic() {
        guard let url = Bundle.main.url(forResource: "gamemusic", withExtension: "mp3") else {
            print("Gamemusic hittades inte.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Fel vid uppspelning av gamemusic: \(error.localizedDescription)")
        }
    }

    func stopGameMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func playButtonSound() {
        guard let url = Bundle.main.url(forResource: "buttonsound", withExtension: "mp3") else {
            print("Ljudfilen hittades inte.")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Fel vid uppspelning av ljud: \(error.localizedDescription)")
        }
    }
}
