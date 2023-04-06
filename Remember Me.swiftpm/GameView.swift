//
//  GameView.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/1/23.
//

import SwiftUI
import AVKit
import SpriteKit


struct GameView: View {
    @EnvironmentObject var gameStatus: GameStatus
    @State var showEndScene = false
    
    var body: some View {
        switch gameStatus.currentScene {
        case GameScene.intro:
            messageConversation(script: "emma_intro", npcName: "Emma", npcIcon: "wife", preloadedChatHistory: []).environmentObject(gameStatus)
        case GameScene.market:
            Market().environmentObject(gameStatus)
        case GameScene.checkout:
            messageConversation(script: "checkout", npcName: "Cashier", npcIcon: "cashier").environmentObject(gameStatus)
        case GameScene.wallet:
            Wallet().environmentObject(gameStatus)
        case GameScene.taxi:
            messageConversation(script: "taxi", npcName: "Taxi Driver", npcIcon: "driver").environmentObject(gameStatus)
        case GameScene.memory:
            MemoryFinder(isDramatic: true).environmentObject(MemorySceneStatus(boardFile: "memory")).environmentObject(gameStatus)
        case GameScene.end:
            EndScene().environmentObject(gameStatus)
        default:
            EndScene()
            
        }
        
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
