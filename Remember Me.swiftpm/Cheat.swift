//
//  GameCheat.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/5/23.
//

import Foundation
import SwiftUI

class Cheat: ObservableObject {
    @Published var isSkip: Bool = false
    @Published var hintContent: String = ""
    
    init(hintContent: String) {
        self.hintContent = hintContent
    }
    
    func skipScene() {
        self.isSkip = true
    }
}


struct SkipSheet: View {
    @EnvironmentObject private var cheat: Cheat
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VStack {
                Image("hint")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .clipped()
                Text("Too challenging?")
                    .font(.largeTitle.weight(.semibold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
            VStack {
                Text(cheat.hintContent)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                Button(action: dismissSheet) {
                    Capsule(style: .continuous)
                        .frame(width: 150, height: 50)
                        .clipped()
                        .foregroundColor(.orange)
                        .overlay {
                            Text("Continue Playing")
                                .foregroundColor(.white)
                        }
                        .padding(.bottom)
                }
            }
            VStack {
                Text("Still cannot finish the objectives?")
                    .font(.body.weight(.semibold))
                Text("That’s okay. This game is designed to be hard and frustrating.")
                Text("You can skip this scene and come back later.")
                Button(action: skipScene) {
                    Capsule(style: .continuous)
                        .frame(width: 150, height: 50)
                        .clipped()
                        .foregroundColor(.black)
                        .overlay {
                            Text("Skip Scene")
                        }
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .clipped()
            .padding()
        }
    }
    
    func skipScene() {
        self.cheat.isSkip = true
        self.isPresented = false
    }
    
    func dismissSheet() {
        self.isPresented = false
    }
}

