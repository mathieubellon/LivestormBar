//
//  OnboardingView.swift
//  LivestormBar
//
//  Created by Mathieu Bellon on 29/04/2022.
//

import SwiftUI

struct OnboardingView: View {
    @State private var fullText: String = "Take some notes for this meeting - DEMO ONLY CONTENT IS NOT SAVED"

    var body: some View {
        VStack(alignment: .center) {
            HStack{
                Text("LivestormBar installed 🎉").font(.system(size: 30)).bold().padding(10)
            }.padding()
            VStack (alignment: .leading, spacing: 10.0){
                Text("Click on logo > Preferences > Connect your Google calendar ").font(.system(size: 20))
                Text("Then you can register your custom shortcut to go to your next meeting in no time").font(.system(size: 20))
            }
            Image(nsImage: NSImage(named: "youdidit")!).resizable().frame(width: 911.75, height: 600.0).padding()

        }
    }
}


struct OnboardingView_Previews: PreviewProvider{
    static var previews: some View{
        OnboardingView()
            .frame(width: 600.0, height: 700.0)
    }
}

