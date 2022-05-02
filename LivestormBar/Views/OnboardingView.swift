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
            Text("Application installée").font(.system(size: 40)).bold().underline()
            Image(nsImage: NSImage(named: "meeting_room")!).resizable().frame(width: 600.0, height: 600.0)

        }
    }
}


struct OnboardingView_Previews: PreviewProvider{
    static var previews: some View{
        OnboardingView()
    }
}

