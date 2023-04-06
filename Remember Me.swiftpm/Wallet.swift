//
//  Wallet.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/2/23.
//

import SwiftUI

private enum CardType {
    case valid_credit
    case id
    case expired_credit
    case bad_debit
    case WWDC_ticket
    case none
}

private class SceneStatus: ObservableObject {
    @Published var disorderLevel: Double = 0.00
    var passwordTracker: Int = 0
    @Published var objectiveComplete = false
    @Published var selectCardType: CardType = CardType.none
    @Published var readyForPassword = true
    @Published var showLoading = false
    let paymentSound = AudioEffectPlayer(sound: "applepay")

    
    func updatePasswordTracker() {
        self.passwordTracker += 1
        if (self.passwordTracker == 6) {
            showLoading = true
            _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {timer in
                self.paymentSound.playAduio()
                self.objectiveComplete = true
            }
        }
    }
    
    func skipsheetSkip() {
        showLoading = true
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {timer in
            self.paymentSound.playAduio()
            self.objectiveComplete = true
        }
    }

    
}
struct Wallet: View {
    @EnvironmentObject var gameStatus: GameStatus
    @StateObject var cheat = Cheat(hintContent: "You’re trying to recall your credit card PIN.\nThis is the classic memory game called Concentration (or Shinkei-suijaku).\nYou need to match cards with same icon.\nTap a card to reveal its icon.\nMatch all cards to pass this scene.\n\nWe strongly discourage skipping this scene, since it involves one of the basic mechanism for this game.")
    @State var showSkipsheet: Bool = false
    @StateObject private var sceneStatus = SceneStatus()
    @StateObject private var memoryScene = MemorySceneStatus(boardFile: "wallet", disableDisorderLevel: true)
    @State var password = ["⚪️","⚪️","⚪️","⚪️","⚪️","⚪️"]

    var body: some View {
        
        VStack(alignment: .center) {
            ZStack {
                Button(action: showSkipSheetToggle) {
                    Image(systemName: "lock.open.trianglebadge.exclamationmark")
                        .symbolRenderingMode(.multicolor)
                        .font(.body)
                        .foregroundColor(.red)
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 100)
                
                VStack {
                    Text("Please Enter Your PIN")
                        .font(.title)
                        .bold()
                    
                    Text("(Try swiping your card)")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 30) {
                VStack {
                    Text("Tap to reveal a card.")
                    Text("👆🏻 -> 🔎")
                }
                
                VStack {
                    Text("Match cards with same icon to enter PIN")
                    Text("🍋 〰️ 🍋")
                }.padding()
            }
        }.frame(alignment: .top)
        .padding(.top, 25)
        .sheet(isPresented: $showSkipsheet, onDismiss: skipsheetCallBack) {
            SkipSheet(isPresented: $showSkipsheet).environmentObject(cheat)
        }
            
        ZStack {
            Image("ssc")
                .resizable()
                .frame(width: 500, height: 314)
                .scaledToFit()
                .cornerRadius(10)
            
            CardView(cardName: "applecard")
                .frame(width: 500, height: 314)
            
        }
            
        VStack {
            if (sceneStatus.showLoading) {
                if (sceneStatus.objectiveComplete) {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 64, weight: .regular, design: .default))
                            .foregroundColor(.blue)
                            .padding()
                        Text("Thank you for shopping with us.")
                            .font(.title)
                        Text("Please take your receipt.")
                            .foregroundColor(.gray)
                    }.animation(Animation.easeIn, value: 1)
                        .padding(.top, 20)
                    Spacer()
                    Button(action: switchScene) {
                        Capsule(style: .continuous)
                            .frame(width: 150, height: 50)
                            .clipped()
                            .foregroundColor(.black)
                            .overlay {
                                Text("Head Home")
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 30)
                    }
                } else {
                    ProgressView("Processing your payment...")
                        .font(.body)
                }
                
            } else {
                HStack {
                    ForEach(self.password, id:\.self) {item in
                        Text(item)
                            .font(.largeTitle)
                    }
                }.onChange(of: memoryScene.pairedCards.count) {_ in
                    let i = memoryScene.pairedCards.count - 1
                    if (i >= 0) {
                        self.password[i] = memoryScene.pairedCards[i].content
                        sceneStatus.updatePasswordTracker()
                    }
                }
                
                ForEach(0..<3) {i in
                    HStack {
                        ForEach(0..<4) {j in
                            let card = memoryScene.cards[(j + i*4)]
                            MemoryCardButton(card: card).environmentObject(gameStatus).environmentObject(memoryScene)
                        }
                    }.padding()
                }
            }
            
        }.frame(width: 600, height: 600)
    }
    

    private func skipsheetCallBack() {
        if(cheat.isSkip) {
            self.sceneStatus.skipsheetSkip()
        }
    }
    
    private func showSkipSheetToggle() {
        self.showSkipsheet = true
        self.sceneStatus.objectiveComplete = true
    }
    
    private func switchScene() {
        self.gameStatus.currentScene = GameScene.taxi
    }
}

struct CardView: View {
    @State private var translation: CGSize = .zero
    var cardName: String
    private func getGesturePercentage(_ geometry: GeometryProxy, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    private var thresholdPercentage: CGFloat = 0.5
    
    init(cardName: String) {
        self.cardName = cardName
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Robert Brown")
                            .font(.title)
                            .bold()
                        Text("Exp  03/28")
                            .font(.subheadline)
                            .bold()

                    }
                    .foregroundColor(.white)
                    Spacer()
                    
                }.padding(.horizontal)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .padding(.bottom)
            .background(Image(cardName).resizable())
            .cornerRadius(10)
            .shadow(radius: 5)
            .animation(.interactiveSpring())
            .offset(x: self.translation.width, y: 0)
            .rotationEffect(.degrees(Double(self.translation.width / geometry.size.width) * 25), anchor: .bottom)
                       .gesture(
                           DragGesture()
                               .onChanged { value in
                                   self.translation = value.translation
                               }.onEnded { value in
                                   self.translation = .zero
                               }
                       )
            
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardName: "card").frame(height: 400).padding()
    }
}
