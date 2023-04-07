/*
 ⚠️ Please view this important note⚠️
 
 Thank you for playing Remember Me. Please be aware of the following two comments when running this app with Swift Playgrounds on iPadOS.

 1. This game is designed to take advantage of screen space in Portrait Mode. Please use Portrait Mode for best experience.

 2. Please wait until the App Preview has fully loaded (indicated by the background music starting) before hitting the “run app” button. Otherwise, the BGM may stop playing when the game starts. (If that does happen, please stop the app, wait until App Preview fully loaded, then start the app).

 This two issues are related to the Playgrounds app on iPadOS (this app is built with Xcode on Mac). It works with no problem if run from Xcode, but I hope you can experience this game in a real iPad rather than a simulator 😊

 The App Preview should has been fully loaded when you read this line. Thanks again for experiencing my game. Have fun!
 */


import SwiftUI
import SpriteKit

public enum GameScene {
    case intro
    case market
    case checkout
    case wallet
    case taxi
    case memory
    case end
}
public class GameStatus: ObservableObject {
    @Published var currentScene: GameScene
    @Published var disorderLevel: Int
    @Published var chatHistory: [messageBubbleItem]
    var bgmPlayer = AudioEffectPlayer(sound: "theme")
    
    init() {
        self.currentScene = GameScene.intro
        self.disorderLevel = 0
        self.chatHistory = []
        bgmPlayer.setLoop()
        bgmPlayer.playAduio()
    }
    
}

struct ContentView: View {
    @StateObject var gameStatus = GameStatus()
    @State var isShowingText = false
    @State var isStartGame = false
    
    var body: some View {
        if (!isStartGame) {
            ZStack{
                if (isShowingText) {
                    SpriteView(scene: BackScene()).ignoresSafeArea()
                }
                VStack {
                    GifImage("title")
                        .frame(width:700, height: 300, alignment:.center)
                        .padding(.top, 20)
                        .transition(.slide)
                        .allowsHitTesting(false)
                        .onAppear(perform: {
                            Timer.scheduledTimer(withTimeInterval: 6, repeats: false) {_ in
                                withAnimation(.easeIn(duration: 2.6)) {
                                    isShowingText.toggle()
                                }
                            }
                        })
                    if isShowingText {
                        if #available(iOS 16.0, *) {
                            Text("a game of love and tear, \n remebering and forgetting")
                                .multilineTextAlignment(.center)
                                .font(.system(.title3, design: .serif))
                                .foregroundColor(.white)
                                .transition(.push(from: .bottom))
                        } else {
                            Text("a game of love and tear, \n remebering and forgetting")
                                .font(.system(.title3, design: .serif))
                                .transition(.slide)
                        }
                        Spacer()
                        
                        Text("How to play")
                            .font(.system(.title3).weight(.bold))
                            .padding()
                            .foregroundColor(.white)
                        
                        Text("Live the life of Robert.\n Interact with people.\n Finish objective.\n And try your best to remeber.")
                            .font(.system(.body))
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                            .foregroundColor(.white)
                        
                        VStack {
                            HStack {
                                Image(systemName: "ipad")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Image(systemName: "ipad.gen1")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            Text("Please use Portrait mode for best experience")
                                .bold()
                                .padding(.bottom)
                                .foregroundColor(.white)
                            
                            
                            Text("Important note for gameplay")
                                .bold()
                                .foregroundColor(.white)

                            Text("During your gameplay, you may find the following icons")
                                .padding(.bottom)
                                .foregroundColor(.white)
                            
                            VStack {
                                HStack {
                                    Image(systemName: "brain")
                                        .font(.body)
                                        .foregroundColor(.orange)
                                    Text("Recall your memory / cognition")
                                        .foregroundColor(.white)
                                } .padding(2)
                                Text("(When your cognition become blurry, quickly tap 🧠 to make it clear)")
                                    .foregroundColor(.white)
                                HStack {
                                    Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                                        .font(.body)
                                        .foregroundColor(.blue)
                                    Text("Open Messages to review chat history")
                                        .foregroundColor(.white)
                                }.padding(2)
                                Text("(You can review Messages when you need information)")
                                    .foregroundColor(.white)
                                HStack {
                                    Image(systemName: "lock.open.trianglebadge.exclamationmark")
                                        .font(.body)
                                        .foregroundColor(.red)
                                    Text("(A game cheat) View hints or skip current scene")
                                        .foregroundColor(.white)
                                }.padding(2)
                                Text("(Feel free to use this when you get stuck)")
                                    .foregroundColor(.white)
                            }
                            
                        }
                       

                        Spacer()
                        Button(action: startGame) {
                            
                            Capsule(style: .continuous)
                                .frame(width: 150, height: 50)
                                .clipped()
                                .foregroundColor(.white)
                                .overlay {
                                    Text("Start Game")
                                }
                                .padding(.bottom)
                        }
                        Spacer()
                        
                    }
                      
                }
            }
           
        } else {
            GameView().environmentObject(gameStatus)
        }
        
        
    }
    
    func startGame() {
        self.isStartGame.toggle()
    }
}
