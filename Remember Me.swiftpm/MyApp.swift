/*
 ⚠️ Please view this important note⚠️
 
 Thank you for playing Remember Me. Please be aware of the following two comments when running this app with Swift Playgrounds on iPadOS.

 1. This game is designed to take advantage of screen space in Portrait Mode. Please use Portrait Mode for best experience.

 2. Please wait until the App Preview has fully loaded (indicated by the background music starting) before hitting the “run app” button. Otherwise, the BGM may stop playing when the game starts. (If that does happen, please stop the app, wait until App Preview fully loaded, then start the app).

 This two issues are related to the Playgrounds app on iPadOS (this app is built with Xcode on Mac). It works with no problem if run from Xcode, but I hope you can experience this game in a real iPad rather than a simulator 😊

 The App Preview should has been fully loaded when you read this line. Thanks again for experiencing my game. Have fun!
 */

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}

struct Previews_MyApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
