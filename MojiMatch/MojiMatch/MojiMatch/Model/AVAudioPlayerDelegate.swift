//
//  AVAudioPlayerDelegate.swift
//  MojiMatch
//
//  Created by Natalie S on 2025-06-05.
//

import AVFoundation


class AVAudioPlayerDelegateWrapper: NSObject, AVAudioPlayerDelegate {
    let onFinished: () -> Void
    
    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished()
    }
}
