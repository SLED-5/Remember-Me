//
//  AudioEffectPlayer.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/1/23.
//

import AVKit

class AudioEffectPlayer: ObservableObject {
    var audioPlayer: AVAudioPlayer
    var sound: String
    init(sound: String) {
        self.sound = sound
        self.audioPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: self.sound, withExtension: "mp3")!)
        self.audioPlayer.prepareToPlay()
    }
    
    func playAduio() {
        self.audioPlayer.play()
    }
    
    func pauseAudio(){
        self.audioPlayer.pause()
    }
    
    func volumeDown() {
        self.audioPlayer.setVolume(0.6, fadeDuration: 1)
    }
}
