//
//  Market.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/1/23.
//

import SwiftUI
import AVKit
import AVFoundation

public struct Product: Codable, Identifiable, Equatable {
    public var id: String
    var text: String
    var price: Float
}

private class SceneStatus: ObservableObject {
    
    struct PackedProduct {
        var uuid: UUID
        var product: Product
    }
    
    
    @Published var disorderLevel: Double = 0.00
    @Published var objectiveComplete = false
    @Published var currentTip: Tip
    var tips: [Tip] = []
    @Published var showTip = true
    @Published var productsInCarts: [PackedProduct]
    @Published var total: Float
    var sfxPlayer: AudioEffectPlayer
    weak var timer: Timer?
    
    var progressTracker: Set<String> = []
    var objectives: Set<String> = ["🧅", "🍇", "🥚", "🥩", "🥓", "🍋", "🍌", "🥐", "🫛", "🌶️", "🫐", "🌷"]
    
    init() {
        for _ in 0..<3 {
            let Tip = Tip(from: "Robert", content: "Emma gave me a shopping list.", instruction: "Tap to buy groceries.\nOpen Messages to check your shopping list.")
            tips.append(Tip)
        }
        for _ in 3..<6 {
            let Tip = Tip(from: "Robert", content: "What are these things?", instruction: "Your symptoms are getting worse.\nQuickly tap 🧠 to recall.")
            tips.append(Tip)
        }
        for _ in 6..<10 {
            let Tip = Tip(from: "Robert", content: "Everything are so strange", instruction: "Your cognition is collapsing.\nTry recall harder by quickly tapping 🧠.")
            tips.append(Tip)
        }
        self.currentTip = tips[0]
        self.productsInCarts = []
        self.total = 0.00
        self.sfxPlayer = AudioEffectPlayer(sound: "arcade_tap")
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {timer in
//            print(self.disorderLevel)
            self.updateDisorderLevel()
        }
    }
    
    func updateProgress(item: Product) {
        if (objectives.contains(item.text) && !progressTracker.contains(item.text) ) {
            progressTracker.insert(item.text)
        }
        if (progressTracker.count == 12) {
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
    
    func updateCart(product: Product) {
        let packedProduct = PackedProduct(uuid: UUID(), product: product)
        self.productsInCarts.append(packedProduct)
        self.total += product.price
        self.updateProgress(item: product)
        self.sfxPlayer.playAduio()
    }
}

struct Market: View {
    @StateObject var cheat = Cheat(hintContent: "In this scene, you can tap a grocery icon to add it to your cart.\nYou need to finish the shopping list to pass this scene.\nRemember Emma gave you a shopping list? You can tap 💬 icon to review it.\nAs time pass, your cognition and memory will collapse, and the objects will become blurry. Quickly tap 🧠 icon to restore your cognition.\n\nOnce you complete your objectives, tap \"Checkout\" button to continue. \n\n We strongly discourage skipping this scene, since it involves one of the basic mechanism for this game.")
    @StateObject private var sceneStatus = SceneStatus()
    @EnvironmentObject var gameStatus: GameStatus
    var audioPlayer: AVAudioPlayer!
    init() {
        let sound = Bundle.main.url(forResource: "market", withExtension: "mp3")!
        self.audioPlayer = try! AVAudioPlayer(contentsOf: sound)
        self.audioPlayer.play()
    }
    var body: some View {
        VStack {
            topView().environmentObject(sceneStatus).environmentObject(gameStatus).environmentObject(cheat)
            Spacer()
            Shelf().environmentObject(sceneStatus)
            Spacer()
            cartView().environmentObject(sceneStatus).environmentObject(gameStatus)
            Spacer()
            
        }
    }
}

private struct topView: View {
    @State var showObjective = false
    @State var showMessage = false
    @State var showSkipsheet = false
    @EnvironmentObject var sceneStatus: SceneStatus
    @EnvironmentObject var gameStatus: GameStatus
    @EnvironmentObject var cheat: Cheat
    
    var body: some View {
        HStack {
            if (sceneStatus.showTip) {
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
                    VStack(alignment: .leading) {
                        Text(sceneStatus.currentTip.content)
                            .font(.title2)
                            .bold()
                        Text(sceneStatus.currentTip.instruction)
                            .font(.body)
                            .foregroundColor(.gray)
                    }.frame(minWidth: 400)
                }
                
            }
            Button(action: recallTip) {
                Image(systemName: "brain")
                    .padding()
                    .font(.title)
            }
            
            Button(action: toggleShowMessage) {
                Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                    .foregroundColor(.blue)
                    .padding()
                    .font(.title)
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
//        sceneStatus.objectiveComplete = true
        self.showSkipsheet = true
    }
    
    private func recallTip() {
        sceneStatus.reduceDisorderLevel()
    }
    private func toggleShowMessage() {
        self.showMessage = true
    }
}

private struct Shelf: View {
  
    var products: [Product]
    @State var productCounter: Int = 0
    @EnvironmentObject var sceneStatus: SceneStatus
    init() {
        self.products = loadProducts()

    }
    var body: some View {
        VStack {
            ForEach(1..<6) {i in
                HStack {
                    ForEach(1..<8) {j in
                        let product = products[(j-1) + (i-1)*7]
                        Button(action:{addToCart(product: product)}) {
                            ProductButton(symbol: product.text, price: product.price, color: Color(.tertiarySystemFill), isCart: false)
                        }
                        
                    }
//                    Spacer()
                    
                }.padding()
            }
        }
    }
    
    func addToCart(product: Product) {
        sceneStatus.updateCart(product: product)
    }
}

private struct cartView: View {
    @EnvironmentObject var sceneStatus: SceneStatus
    @EnvironmentObject var gameStatus: GameStatus
    @State var cartCount: Int = 0
    var body: some View {
        VStack {
            Text("Your Shopping Cart")
                .font(.headline)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(sceneStatus.productsInCarts, id: \.uuid) {item in
                            let product = item.product
                            ProductButton(symbol: product.text, price: product.price, color: Color(.brown).opacity(0.2), isCart: true).environmentObject(sceneStatus).id(item.uuid)
                        }
                    }.padding()
                }.onChange(of: sceneStatus.productsInCarts.count) {_ in
                    proxy.scrollTo(sceneStatus.productsInCarts.last?.uuid)
                }
            }
            
        }
        Text("Total")
        Text("$ \(self.roundTotal(total: sceneStatus.total))")
            .font(.system(.largeTitle, design: .rounded).weight(.bold))
            .padding(.bottom)
            
           
        if (sceneStatus.objectiveComplete) {
            Button(action: switchToCheckout) {
                Capsule(style: .continuous)
                    .frame(width: 150, height: 50)
                    .clipped()
                    .foregroundColor(.black)
                    .overlay {
                        Text("Checkout")
                            .foregroundColor(.white)
                    }
                    .padding(.bottom)
            }
        }
        
            
    }
    
    func roundTotal(total: Float) -> String {
        let str = String(format: "%.2f", total)
        if (sceneStatus.disorderLevel < 5) {
            return str
        } else {
            var chars = Array(str)

            if (sceneStatus.disorderLevel >= 10) {
                for i in 0..<chars.count {
                    if(chars[i] != ".") {
                        chars[i] = "�"
                    }
                }
                return String(chars)
            } else {
                for _ in 1...3 {
                    chars[Int.random(in: 1..<chars.count)] = "�"
                }
                return String(chars)
            }
            
            
        }
        
    }
    
    func switchToCheckout() {
        self.gameStatus.currentScene = GameScene.checkout
    }
}

struct ProductButton: View {
    var symbol: String
    var price: Float
    var color: Color
    var isCart: Bool
    @EnvironmentObject private var sceneStatus: SceneStatus
    init(symbol: String, price: Float, color: Color, isCart: Bool) {
        self.symbol = symbol
        self.price = price
        self.color = color
        self.isCart = isCart
    }
    var body: some View {
        makeButtonView(isCart: isCart)
    }
    
    func makeButtonView(isCart: Bool) -> AnyView {
//        let a = print(sceneStatus.disorderLevel)
        if (!isCart) {
            return AnyView(
                Text(symbol)
                    .font(.system(size: 60, weight: .medium, design: .default))
                    .blur(radius: CGFloat(1.1 * sceneStatus.disorderLevel))
                    .padding(.vertical, 9)
                    .padding(.horizontal, 14)
                    .background(color)
                    .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                    .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
            )
        } else {
            return AnyView(
                Text(symbol)
                    .font(.system(size: 60, weight: .medium, design: .default))
                    .padding(.vertical, 9)
                    .padding(.horizontal, 14)
                    .background(color)
//                    .opacity(0.1)
                    .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                    .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
        
        
    }
}

struct Market_Previews: PreviewProvider {
    static var previews: some View {
        Market()
    }
}
