//
//  Conversation.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/1/23.
//

import SwiftUI
import AVKit


public struct dialogue: Codable {
    var npc: [String]
    var player: [String: String]
    var playerMsg: [String: String]
    var specialResponse: [String: String]
    var nextScene: String
}

class MessageStatus: ObservableObject {
    @Published var playername = ""
    @Published var npcName = ""
    @Published var npcIcon = ""
    @Published var nextMessage = false
    @Published var isPreloaded: Bool
    @Published var chatHistory: [messageBubbleItem]
    @Published var quickResponseButtons: [String:String] = [:]
    @Published var currentMessageId = 0
    @Published var updateConversation = false
    @Published var switchNextScene = false
    @Published var nextScene: String = ""
    var currentDialogueId = 0
    var dialogueSequence: [dialogue]
    var currentDialogue: dialogue
    
    init(script: String, npcName: String, npcIcon: String, preloadedChatHistory: [messageBubbleItem], isPreloaded: Bool) {
        self.npcName = npcName
        self.npcIcon = npcIcon
        self.dialogueSequence = loadDialogueScript(script: script)
        self.currentDialogue = dialogueSequence[0]
        self.chatHistory = preloadedChatHistory
        self.isPreloaded = isPreloaded
        if(!isPreloaded) {
            saveNpcChatHistory()
        }
    }
    
    func saveNpcChatHistory() {
        if (currentDialogue.nextScene == "") {
            for item in getNpcMsg() {
                chatHistory.append(messageBubbleItem(id: UUID(), fromPlayer: false, content: item))
                currentMessageId+=1
                quickResponseButtons = currentDialogue.player
            }
        } else {
            self.switchNextScene = true
            self.nextScene = currentDialogue.nextScene
        }
        
    }
    func getPlayerMsgTitle() -> [String:String] {
        return currentDialogue.player
    }
    
    func getPlayerMsgFull(selection: String) -> String {
        return self.currentDialogue.playerMsg[selection]!
    }
    
    func getNpcMsg() -> [String] {
        return currentDialogue.npc
    }
    
    func getSpecialResonse(selection: String) -> String {
        return currentDialogue.specialResponse[selection]!
    }
    
    func savePlayerResponseHistory(key: String, fullMsg: String) {
        chatHistory.append(messageBubbleItem(id: UUID(), fromPlayer: true, content: fullMsg))
        currentMessageId+=1
        checkSpecialResponse(key: key)
    }
    func checkSpecialResponse(key: String) {
        if(currentDialogue.specialResponse.keys.contains(key)) {
            var specialResponse: String = currentDialogue.specialResponse[key]!
            if (specialResponse == "#GREETINGS#") {
                specialResponse = "Awesome! Nice to mee you \(self.playername)"
            }
            chatHistory.append(messageBubbleItem(id: UUID(), fromPlayer: false, content: specialResponse))
            currentMessageId += 1
        }
        switchNextDialogue()
    }
    func switchNextDialogue() {
        currentDialogueId += 1
        if (currentDialogueId < dialogueSequence.count) {
            currentDialogue = dialogueSequence[currentDialogueId]
        }
        saveNpcChatHistory()
    }
}

public struct messageConversation: View {
    @StateObject var messageStatus: MessageStatus
    @EnvironmentObject var gameStatus: GameStatus
    
    public init(script: String, npcName: String, npcIcon: String, preloadedChatHistory: [messageBubbleItem] = [], isPreloaded: Bool = false) {
        _messageStatus = StateObject(wrappedValue: MessageStatus(script: script, npcName: npcName, npcIcon: npcIcon, preloadedChatHistory: preloadedChatHistory, isPreloaded: isPreloaded))
    }
    public var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.secondary)
                .overlay(
                    VStack {
                        Image(messageStatus.npcIcon)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                        Text(messageStatus.npcName)
                            .foregroundColor(.white)
                            .bold()
                    }
                ).frame(height: 120)
            Spacer()
            conversationView()
                .environmentObject(messageStatus)
            if (!messageStatus.isPreloaded) {
                qucikResponse().environmentObject(gameStatus)
                    .environmentObject(messageStatus)
            }
        }
    }
}

public struct messageBubble: View {
    var content: String
    var fromPlayer: Bool
    public var body: some View {
        if (fromPlayer){
            return AnyView(
                HStack{
                    Spacer()
                    Text(content).padding().foregroundColor(.white).background(.blue).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))}.padding(.leading, 55).padding(.vertical, 10))
            
        }else {
            return AnyView(
                HStack{
                    Text(content).padding().foregroundColor(.primary).background(Color.secondary.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    Spacer()
                }.padding(.trailing, 60).padding(.vertical, 10))
        }
    }
}



struct qucikResponse: View {
    @EnvironmentObject var messageStatus: MessageStatus
    @EnvironmentObject var gameStatus: GameStatus
    @StateObject var sfxPlayer = AudioEffectPlayer(sound: "messageSent")

    var body: some View {
        HStack {
            if (messageStatus.switchNextScene) {
                responseButton(content: getNextSceneTitle(), key: "1", isSceneSwitch: true).environmentObject(gameStatus).environmentObject(sfxPlayer)
            } else {
                ForEach(messageStatus.quickResponseButtons.keys.sorted(), id: \.self) { key in
                    responseButton(content: messageStatus.quickResponseButtons[String(key)]!, key: key, isSceneSwitch: false).environmentObject(gameStatus).environmentObject(sfxPlayer)
                }
            }
            
        }.padding()
        
   }
    
    func getNextSceneTitle() -> String {
        switch gameStatus.currentScene {
        case GameScene.intro:
            return "Go to market"
            
        case GameScene.checkout:
            return "Check wallet"
        
        case GameScene.taxi:
            return "Dive into Memory"
            
        default:
            return "Go to WWDC"
        }
    }
}

struct conversationView: View {
    @State var isNewMsgDelay = true
    @EnvironmentObject var messageStatus: MessageStatus
    
    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    ForEach(messageStatus.chatHistory, id: \.id) { item in
                        messageBubble(content: item.content, fromPlayer: item.fromPlayer).id(item.id)
                    }
                }.padding(.horizontal, 20)
                    .animation(.easeOut(duration: 0.16))
            }.onChange(of: messageStatus.chatHistory.count) {_ in
                proxy.scrollTo(messageStatus.chatHistory.last?.id)
            }
            
        }
        
    }
}

public struct messageBubbleItem: Identifiable, Equatable {
    public var id: UUID
    let fromPlayer: Bool
    var content: String
}



struct responseButton: View {
    @EnvironmentObject var sfxPlayer: AudioEffectPlayer
    @EnvironmentObject var gameStatus: GameStatus
    @EnvironmentObject var messageStatus: MessageStatus
    @State var isHidden: Bool = false
    var content: String
    var key: String
    var color: Color
    var isSceneSwitch: Bool
    
    init(content: String, key: String, isSceneSwitch: Bool) {
        self.content = content
        self.key = key
        self.isSceneSwitch = isSceneSwitch
        if (isSceneSwitch) {
            self.color = Color(.black)
        } else {
            self.color = Color(.tertiarySystemFill)
        }
    }
    var body: some View {
        Button(action: submitResponse) {
            Text(self.content)
                .font(.system(size: 16, weight: .medium, design: .default))
                .padding(.vertical, 9)
                .padding(.horizontal, 14)
                .background(self.color)
                .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
    func submitResponse() {
        if (isSceneSwitch) {
            gameStatus.chatHistory = messageStatus.chatHistory
            switch messageStatus.nextScene {
            case "market":
                gameStatus.currentScene = GameScene.market
                
            case "wallet":
                gameStatus.currentScene = GameScene.wallet
            
            case "memory":
                gameStatus.currentScene = GameScene.memory
                
            default:
                gameStatus.currentScene = GameScene.intro
            }
            
           
            
        } else {
            sfxPlayer.playAduio()
            messageStatus.savePlayerResponseHistory(key: self.key, fullMsg: self.content)
            self.isHidden = true
        }
        
    }
    func submitResponse(fullMsg: String) {
        messageStatus.savePlayerResponseHistory(key: self.key, fullMsg: fullMsg)
        self.isHidden = true
    }
        
    func badEnding() {
       print("Bad")
    }
}

