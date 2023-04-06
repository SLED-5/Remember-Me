//
//  MemorySceneStatus.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/4/23.
//

import Foundation

enum RevealStatus {
    case paired
    case unpaired
    case pending
}


class MemorySceneStatus: ObservableObject {
    
    struct PackedMemoryCard {
        var uuid: UUID
        var memoryCard: MemoryCard
    }
    
    @Published var disorderLevel: Double = 0.00
    @Published var objectiveComplete = false
    @Published var currentTip: Tip
    var disableDisorderLevel: Bool
    var tips: [Tip] = []
    var cards: [MemoryCard] = []
    var boardFile: String
    @Published var isSuccess: Bool = false
    @Published var isFailure: Bool = false
    @Published var cardContent: String = ""
    @Published var showMemoryCard = true
    @Published var revealedMemoryCard: Set<String>
    var tapPlayer: AudioEffectPlayer
    var winPlayer: AudioEffectPlayer
    var losePlayer: AudioEffectPlayer
    weak var timer: Timer?
    @Published var pairedCards: [MemoryCard] = []
    var progressTracker: Int = 0

    
    init(boardFile: String, disableDisorderLevel: Bool = false) {
        for _ in 0..<3 {
            let tip = Tip(from: "Robert", content: "These fragments feel so familiar...", instruction: "Tap and pair memory fragments.\nAct quickly or they will fade out.")
            tips.append(tip)
        }
        for _ in 3..<6 {
            let tip = Tip(from: "Robert", content: "I feel like losing something in time...", instruction: "Your cognition is collapsing.\nQuickly tap 🧠 to recall memory.")
            tips.append(tip)
        }
        for _ in 6..<10 {
            let tip = Tip(from: "Robert", content: "I was abandon, alone in a blurry time.", instruction: "You symptoms are getting worse.\nTry recall harder by quickly tapping 🧠.")
            tips.append(tip)
        }
        self.disableDisorderLevel = disableDisorderLevel
        self.currentTip = tips[0]
        self.revealedMemoryCard = []
        self.tapPlayer = AudioEffectPlayer(sound: "arcade_tap")
        self.winPlayer = AudioEffectPlayer(sound: "arcade_win")
        self.losePlayer = AudioEffectPlayer(sound: "arcade_lose")
        self.boardFile = boardFile
        
        if (!disableDisorderLevel) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {timer in
                self.updateDisorderLevel()
            }
        }
        

        self.cards = generateBoard()
    }
    
    func generateBoard() -> [MemoryCard] {
        let preloadData = loadMemoryCard(file: boardFile)
        let shuffle1 = preloadData.shuffled()
        let shuffle2 = preloadData.shuffled()
        var board: [MemoryCard] = []
        
        for i in 0..<preloadData.count {
            board.append(shuffle1[i])
            board.append(shuffle2[i])
        }
        return board
    }
    
    func updateProgress(item: MemoryCard) {
        progressTracker += 1
        if(!pairedCards.contains(item)) {
            pairedCards.append(item)
        }
        print("Card Paired \(item.id). Current progress \(progressTracker)")
        if (progressTracker >= 10) {
            self.objectiveComplete = true
        }
    }
    
    func updateDisorderLevel() {
        self.disorderLevel += 0.06
        if (self.disorderLevel < 10) {
            self.currentTip = tips[Int(self.disorderLevel)]
        }
        if (self.disorderLevel >= 10) {
            self.timer = nil
        }
    }
    
    func reduceDisorderLevel() {
        if (disorderLevel >= 0) {
            self.disorderLevel -= 0.3
            if (self.disorderLevel < 10) {
                self.currentTip = tips[Int(self.disorderLevel)]
            }
        }
    }
    
    func resetDisorderLevel() {
        self.disorderLevel = 0
    }
    

    
    func revealMemoryCard(card: MemoryCard) -> RevealStatus {
        tapPlayer.playAduio()
        if (self.revealedMemoryCard.count == 0) {
            self.revealedMemoryCard.insert(card.id)
            print(revealedMemoryCard)
            print("pending")
            return RevealStatus.pending
        } else {
            var result: RevealStatus
            if (validatePair(card: card)) {
                winPlayer.playAduio()
                updateProgress(item: card)
                result = RevealStatus.paired
                self.cardContent = card.content
                self.isSuccess.toggle()
            } else {
                losePlayer.playAduio()
                result = RevealStatus.unpaired
                self.isFailure.toggle()
            }
            self.revealedMemoryCard = []
//            self.isRefresh.toggle()
            return result
        }
    }
    
    func validatePair(card: MemoryCard) -> Bool {
        return revealedMemoryCard.contains(card.id)
        
    }
}

