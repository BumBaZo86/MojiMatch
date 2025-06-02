//
//  AudioManager.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-02.
//
import Foundation
import AVFoundation

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
    
  
    func pauseBackgroundMusic() {
        audioPlayer?.pause()
    }
    
 
    func resumeBackgroundMusic() {
        audioPlayer?.play()
    }
}
