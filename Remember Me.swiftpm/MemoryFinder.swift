//
//  MemoryFinder.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/2/23.
//

import SwiftUI
import SpriteKit

public struct MemoryCard: Hashable, Codable, Identifiable {
    public var id: String
    var content: String
}

struct MemoryFinder: View {
    var boardFile: String = ""
    @State var isDramatic: Bool
    @State var narratives: [String] = ["As night falls,", "you watch the passing streetscape beside you", "and find yourself caught in a whirlpool of memories.", "Try to pair your memory before they fade out."]
    @State var isShown: Bool = false
    @EnvironmentObject var gameStatus: GameStatus
    @EnvironmentObject var sceneStatus: MemorySceneStatus
    
    init(isDramatic: Bool) {
        self.isDramatic = isDramatic
    }
    
    
    var body: some View {
        
        ZStack {
            SpriteView(scene: BackScene()).blur(radius: abs(CGFloat(1.1 * sceneStatus.disorderLevel))).ignoresSafeArea()
            
            if (isDramatic) {
                
                if (sceneStatus.disorderLevel < 1.5) {
                    Text(narratives[0])
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .animation(.easeInOut(duration: 1))
                }
                
                if (sceneStatus.disorderLevel > 1.5 && sceneStatus.disorderLevel < 3) {
                    Text(narratives[1])
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .animation(.easeInOut(duration: 1))
                }
                
                if (sceneStatus.disorderLevel > 3 && sceneStatus.disorderLevel < 4.5) {
                    Text(narratives[2])
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .animation(.easeInOut(duration: 1))
                }
                
                if (sceneStatus.disorderLevel > 4.5 && sceneStatus.disorderLevel < 6) {
                    Text(narratives[3])
                        .foregroundColor(.orange)
                        .font(.title)
                        .bold()
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        .animation(.easeInOut(duration: 1))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.isDramatic = false
                                sceneStatus.resetDisorderLevel()
                            }
                        }
                }
                

                
                
            } else {
                VStack {
                    topView().environmentObject(sceneStatus).environmentObject(gameStatus)
                    Spacer()
                    
                    ZStack {
                        VStack {
                            ForEach(0..<4) {i in
                                HStack {
                                    ForEach(0..<5) {j in
                                        let card = sceneStatus.cards[(j + i*5)]
                                        MemoryCardButton(card: card).environmentObject(sceneStatus)
                                    }
                                    
                                }.padding()
                            }
                        }.frame(width: 600, height: 600)
                        if(sceneStatus.objectiveComplete) {
                            VStack {
                                Text("You've tried so hard to remeber.\n But eventually, you lost in time.")
                                    .foregroundColor(.white)
                                Button(action: switchScene) {
                                    
                                    Capsule(style: .continuous)
                                        .frame(width: 150, height: 50)
                                        .clipped()
                                        .foregroundColor(.white)
                                        .overlay {
                                            Text("End Scene")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.bottom)
                                }
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, 50)
                            .padding(.horizontal, 40)
                        } else {
                            Text(sceneStatus.cardContent)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, 50)
                                .padding(.horizontal, 40)
                                .font(.system(.title, design: .serif))
                                .foregroundColor(.white)
                                .animation(Animation.easeIn, value: 2)
                        }
                        
                    }
                    Spacer()
                }
            }
        }
    }
    
    
    private func switchScene() {
        gameStatus.currentScene = GameScene.end
    }
}

private struct topView: View {
    @StateObject var cheat = Cheat(hintContent: "Welcome to the finale.\nYou’re on a taxi back home, and start recalling your past.\n\nThis scene combines what you played in last two scenes.\nTap cards to reveal, match cards with same icon to progress.\nAs time pass, your cognition and memory will collapse, and objects will become blurry.\n Quickly tap 🧠 icon to restore your cognition.")
    @State var showObjective = false
    @State var showMessage = false
    @State var showSkipsheet = false
    @EnvironmentObject var sceneStatus: MemorySceneStatus
    @EnvironmentObject var gameStatus: GameStatus
    
    var body: some View {
        HStack {
            if (sceneStatus.showMemoryCard) {
                HStack {
                    Button(action: showSkipSheet) {
                        Image(systemName: "lock.open.trianglebadge.exclamationmark")
                            .padding()
                            .symbolRenderingMode(.multicolor)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    VStack (alignment: .center) {
                        Text("Memory\nCollapse").font(.system(.body, design: .monospaced).weight(.medium)).multilineTextAlignment(.center)
                        Text(String(format: "%0.2f", sceneStatus.disorderLevel))
                    }
                    .foregroundColor(.white)
                    VStack(alignment: .leading) {
                        Text(sceneStatus.currentTip.content)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        Text(sceneStatus.currentTip.instruction)
                            .font(.body)
                            .foregroundColor(.gray)
                    }.frame(minWidth: 460)
                }
                
            }
            Button(action: recallMemoryCard) {
                Image(systemName: "brain")
                    .padding()
                    .font(.largeTitle)
            }
            
        }.padding(.top, 20)
            .sheet(isPresented: $showSkipsheet, onDismiss: skipsheetCallBack) {
                SkipSheet(isPresented: $showSkipsheet).environmentObject(cheat)
            }
        .sheet(isPresented: $showMessage) {
            messageConversation(script: "emma_intro", npcName: "Emma", npcIcon: "wife", preloadedChatHistory: gameStatus.chatHistory, isPreloaded: true)
        }
        
    }
    
    private func skipsheetCallBack() {
        if (self.cheat.isSkip) {
            self.sceneStatus.objectiveComplete = true
        } else {
            self.sceneStatus.resetDisorderLevel()
        }
    }
    
    private func showSkipSheet() {
        self.showSkipsheet = true
        sceneStatus.objectiveComplete = true
    }
    
    private func recallMemoryCard() {
        sceneStatus.reduceDisorderLevel()
    }
    private func callShowMessage() {
        self.showMessage = true
    }
    
}


struct MemoryCardButton: View {
    @State var isBlur: Bool = true
    @State var isShown: Bool = false
    @State var isDestroyed: Bool = false
    @State var symbol: String
    var card: MemoryCard
    @State var color: Color
    var isCart: Bool = false
    @State var allowInteraction = true
    @EnvironmentObject private var sceneStatus: MemorySceneStatus
    init(card: MemoryCard) {
        self.card = card
        self.symbol = card.id
        self.color = Color(.brown).opacity(0.8)
    }
    var body: some View {
        makeButtonView(isCart: isCart)
    }
    
    func makeButtonView(isCart: Bool) -> AnyView {
        if (isDestroyed) {
            return AnyView(
                Text(symbol)
                    .font(.system(size: 60, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0))
                    .padding(.vertical, 9)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0))
                    .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                    .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
            )
        } else {
            if (isShown) {
                
                if (self.isBlur) {
                    return AnyView(
                        Text(symbol)
                            .font(.system(size: 60, weight: .medium, design: .default))
                            .blur(radius: CGFloat(1.1 * sceneStatus.disorderLevel))
                            .foregroundColor(.white)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 14)
                            .background(color)
                            .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                            .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                            .onTapGesture {
                                self.revealCard(card: card)
                            }
                            .onChange(of: sceneStatus.isSuccess) { _ in
                                if (isShown) {destroyCard()}
                            }
                            .onChange(of: sceneStatus.isFailure) { _ in
                                if (isShown) {resetCard()}
                                lockInteraction()
                                
                            }
                            .allowsHitTesting(allowInteraction)
                    )
                } else {
                    return AnyView(
                        Text(symbol)
                            .font(.system(size: 60, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 14)
                            .background(color)
                            .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                            .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                            .onTapGesture {
                                self.revealCard(card: card)
                            }
                            .onChange(of: sceneStatus.isSuccess) { _ in
                                if (isShown) {destroyCard()}
                            }
                            .onChange(of: sceneStatus.isFailure) { _ in
                                if (isShown) {resetCard()}
                                lockInteraction()
                                
                            }
                            .allowsHitTesting(allowInteraction)
                    )
                }
                
            } else {
                return AnyView(
                    Text(symbol)
                        .font(.system(size: 60, weight: .medium, design: .default))
                        .foregroundColor(.blue.opacity(0))
                        .foregroundColor(.white)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(color)
                        .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                        .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                        .onTapGesture {
                            self.revealCard(card: card)
                        }
                        .onChange(of: sceneStatus.isSuccess) { _ in
                            if (isShown) {destroyCard()}
                        }
                        .onChange(of: sceneStatus.isFailure) { _ in
                            if (isShown) {resetCard()}
                            lockInteraction()
                        }
                        .allowsHitTesting(allowInteraction)
                )
            }
        }
    }
    
    
    func lockInteraction() {
        self.allowInteraction = false
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {timer in
            self.allowInteraction = true
        }
    }
    
    func resetCard() {
        if (!isDestroyed) {
            self.color = Color(.red).opacity(0.6)
            _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {timer in
                self.color = Color(.brown).opacity(0.8)
                self.isShown = false
            }
        
        }
    }
    
    func destroyCard() {
        self.isBlur = false
        self.color = Color(.green).opacity(0.6)
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {timer in
            self.isDestroyed = true
        }
        
    }
    
    func revealCard(card: MemoryCard) {
        self.isShown = true
        self.allowInteraction = false
        self.color = .orange.opacity(0.6)
        switch sceneStatus.revealMemoryCard(card: card) {
        case RevealStatus.paired:
            self.isBlur = false
            destroyCard()
        case RevealStatus.unpaired:
            lockInteraction()
            resetCard()
        default:
            break
        }
        
    }
}
