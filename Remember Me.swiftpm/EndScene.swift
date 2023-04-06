//
//  EndScene.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/5/23.
//

import SwiftUI

struct EndScene: View {
    @EnvironmentObject var gameStatus: GameStatus
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GifImage("title")
                    .frame(minHeight: 280, maxHeight: 450)
                    .transition(.slide)
                HStack {
                    Text("Thank you for playing *Remember Me*.")
                        .font(.title.weight(.bold))
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("This game is a briefly representation about a person with Alzheimer’s disease. ")
                    Text("Alzheimer's disease (AD) is a neurodegenerative 🧠 disease that usually starts slowly and progressively worsens")
                    Text("As the disease advances, symptoms can include problems with language, disorientation, mood swings, loss of motivation, self-neglect, and behavioral issues. 😶‍🌫️")
                    Text("As a person's condition declines, they often withdraw from family and society. 🫥")
                    Text("Gradually, bodily functions are lost, ultimately leading to death. 🪦")
                        .padding(.bottom)
                    Text("More than **6 million** Americans are living with Alzheimer's.")
                    Text("By 2050, this number is projected to rise to nearly **13 million**.")
                }.multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("About Gameplay Design")
                        .font(.headline)
                    Text("The two core game mechanics, Progressive Blur and Shinkei-suijaku (Nervous Breakdown) Game, represent the difficulty of maintaining cognition and memory.")
                    Text("The Grocery Store scene introduces the blur mechanism, and the Checkout scene teaches the basic rule of the Shinkei-suijaku (tap and pair). Then the final scene, Lost in Time, combines these two basic mechanisms to provide the greatest challenge, and also a metaphor of losing your memory piece by piece.")
                    Text("I want the player to feel frustrated and helpless when the objects become more and more blurry, and they have to recall harder and harder to continue playing.")
                    Text("The pain is no comparison to the real-life pain of losing recognition of things and memories of beloved ones.")
                    Text("It’s impossible to express even a little part of such pain, not mentioned is such a short experience.")
                    Text("But I still hope you can feel something. Let's love our life, as much as we can 🤘🏻")
                }.multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("About Me")
                        .font(.headline)
                    Text("My name is Enxi (Gabriel) Zhang.")
                    Text("a CS student 👨🏻‍💻  a life enthusiast 🍀")
                }
            }.padding(.horizontal)
            Image("me")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .padding(.bottom)
            
            Text("Replay Scenes")
                .bold()
            
            HStack {
                Button(action: switchMarket) {
                    Text("Grocery Store")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(Color(.tertiarySystemFill))
                        .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                        .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                }
                
                Button(action: switchCheckout) {
                    Text("Checkout")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(Color(.tertiarySystemFill))
                        .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                        .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                }
                
                Button(action: switchFinale) {
                    Text("Lost in Time")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .padding(.vertical, 9)
                        .padding(.horizontal, 14)
                        .background(Color(.tertiarySystemFill))
                        .mask { RoundedRectangle(cornerRadius: 17, style: .continuous) }
                        .shadow(color: Color(.displayP3, red: 0/255, green: 0/255, blue: 0/255).opacity(0.06), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.bottom, 10)
        }
    }
    private func switchMarket() {
        self.gameStatus.currentScene = GameScene.market
    }
    
    private func switchCheckout() {
        self.gameStatus.currentScene = GameScene.wallet
    }
    
    private func switchFinale() {
        self.gameStatus.currentScene = GameScene.memory
    }
        
}

struct EndScene_Previews: PreviewProvider {
    static var previews: some View {
        EndScene()
    }
}
